# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
require "digest"
require "openssl"

class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.13.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/agentdock-runner-0.13.0-darwin-arm64.tar.gz"
      sha256 "88a1fdfe3823ff8a50e165dba3324c71ddebefb02c8864f095e096e762479cf4"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/agentdock-runner-0.13.0-darwin-x64.tar.gz"
      sha256 "95ac98f424a0ee70cf0db565a9b2e003dd273362a817c79a450ba10b9bb7cae7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/agentdock-runner-0.13.0-linux-arm64.tar.gz"
      sha256 "b05da98c9d26f6e3bb778a3629e9e7834657f0e2de0d716944a32f88ef087b2f"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/agentdock-runner-0.13.0-linux-x64.tar.gz"
      sha256 "e4e6717187ab7085e4569d19e98e0571a16113f6465e76e5dd84dbbdb31743aa"
    end
  end

  # SHA256SUMS of the release and its Ed25519 signature (ADR-0049).
  resource "SHA256SUMS" do
    url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/SHA256SUMS"
    sha256 "30c190ce25fe04ac71ed7b6719cb36fec9df5c46c51df514d0e77372e7071dfe"
  end

  resource "SHA256SUMS.sig" do
    url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.13.0/SHA256SUMS.sig"
    sha256 "ea2c4727bcdee94660e30e3bc49cdcd0c7baad152db2bb17d0df1e1242ecfdfa"
  end

  # apps/runner/release-key.pub of AgentDock.
  RELEASE_KEY = <<~PEM.freeze
    -----BEGIN PUBLIC KEY-----
    MCowBQYDK2VwAyEAUZTyf8lH2FdBavFF1oadsbBAOQD9kXfGp4YHCNFB3r8=
    -----END PUBLIC KEY-----
  PEM

  # Raises unless `sums` is signed by `key` and lists `digest` for `name`.
  def self.verify_release!(sums, signature, name, digest, key = RELEASE_KEY)
    signed = begin
      OpenSSL::PKey.read(key).verify(nil, signature, sums)
    rescue OpenSSL::PKey::PKeyError
      false
    end
    raise "agentdock-runner: SHA256SUMS is not signed by the AgentDock release key" unless signed

    listed = sums.each_line.filter_map do |line|
      sha, file = line.split
      sha if file&.delete_prefix("*") == name
    end
    raise "agentdock-runner: SHA256SUMS lists no checksum for #{name}" if listed.empty?
    return if listed.include?(digest)

    raise "agentdock-runner: #{name} does not match its checksum in SHA256SUMS"
  end

  def install
    self.class.verify_release!(
      File.binread(resource("SHA256SUMS").tap(&:fetch).cached_download),
      File.binread(resource("SHA256SUMS.sig").tap(&:fetch).cached_download),
      File.basename(stable.url),
      Digest::SHA256.file(cached_download).hexdigest,
    )
    bin.install "agentdock-runner"
  end

  # Exit 78 is a terminal close (protocol mismatch, revoked token, replaced):
  # restarting can only loop. Service managers restart every non-zero exit, so
  # the wrapper turns 78 into 0 and only an unsuccessful exit is restarted.
  service do
    run ["/bin/sh", "-c", '"$@"; c=$?; [ "$c" -eq 78 ] && exit 0; exit "$c"',
         "agentdock-runner", opt_bin/"agentdock-runner", "run"]
    keep_alive successful_exit: false
    environment_variables PATH: std_service_path_env
    log_path var/"log/agentdock-runner.log"
    error_log_path var/"log/agentdock-runner.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/agentdock-runner version")
  end
end
