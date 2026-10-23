# Rendered from Nautelle's apps/runner/homebrew/nautelle-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
require "digest"
require "openssl"

class NautelleRunner < Formula
  desc "Per-machine daemon of Nautelle, a control plane for agent fleets"
  homepage "https://nautelle.luna-realm.com/"
  version "0.15.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/nautelle-runner-0.15.0-darwin-arm64.tar.gz"
      sha256 "259608db2e006e0a7e31d0d4fe739d7913fb7defbe2113ab04a2dc7e3cb45903"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/nautelle-runner-0.15.0-darwin-x64.tar.gz"
      sha256 "e35252aa4d02ad8df03b523d1bd53cde966d8da07357b48fafc1c3e4e6476dba"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/nautelle-runner-0.15.0-linux-arm64.tar.gz"
      sha256 "a56ac7e17badd00bdeadbdc1fc241e992c910345373a1f4ab53ed2c9233755ca"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/nautelle-runner-0.15.0-linux-x64.tar.gz"
      sha256 "d78c4e6e16445cb4f85015db22e632c00fccc6987259c5efc5d9e4d6619d257c"
    end
  end

  # SHA256SUMS of the release and its Ed25519 signature (ADR-0049).
  resource "SHA256SUMS" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/SHA256SUMS"
    sha256 "c852e3e9d5cf315ca8af79271d77d9759c0821bef0831094045d213de47eb659"
  end

  resource "SHA256SUMS.sig" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.15.0/SHA256SUMS.sig"
    sha256 "f1f6bdc6cd6e9f850c06f2ecc0eb50d3f627d20613e8b2786f13fca228ceccc5"
  end

  # apps/runner/release-key.pub of Nautelle.
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
    raise "nautelle-runner: SHA256SUMS is not signed by the Nautelle release key" unless signed

    listed = sums.each_line.filter_map do |line|
      sha, file = line.split
      sha if file&.delete_prefix("*") == name
    end
    raise "nautelle-runner: SHA256SUMS lists no checksum for #{name}" if listed.empty?
    return if listed.include?(digest)

    raise "nautelle-runner: #{name} does not match its checksum in SHA256SUMS"
  end

  def install
    self.class.verify_release!(
      File.binread(resource("SHA256SUMS").tap(&:fetch).cached_download),
      File.binread(resource("SHA256SUMS.sig").tap(&:fetch).cached_download),
      File.basename(stable.url),
      Digest::SHA256.file(cached_download).hexdigest,
    )
    bin.install "nautelle-runner"
    # ADR-0073: the old command, for a unit or a plugin hook that still names
    # it. Runner 0.16.0 drops it.
    bin.install_symlink bin/"nautelle-runner" => "agentdock-runner"
  end

  # Exit 78 is a terminal close (protocol mismatch, revoked token, replaced):
  # restarting can only loop. Service managers restart every non-zero exit, so
  # the wrapper turns 78 into 0 and only an unsuccessful exit is restarted.
  service do
    run ["/bin/sh", "-c", '"$@"; c=$?; [ "$c" -eq 78 ] && exit 0; exit "$c"',
         "nautelle-runner", opt_bin/"nautelle-runner", "run"]
    keep_alive successful_exit: false
    environment_variables PATH: std_service_path_env
    log_path var/"log/nautelle-runner.log"
    error_log_path var/"log/nautelle-runner.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nautelle-runner version")
  end
end
