# Rendered from Nautelle's apps/runner/homebrew/nautelle-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
require "digest"
require "openssl"

class NautelleRunner < Formula
  desc "Per-machine daemon of Nautelle, a control plane for agent fleets"
  homepage "https://nautelle.luna-realm.com/"
  version "0.17.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/nautelle-runner-0.17.0-darwin-arm64.tar.gz"
      sha256 "3e224ad5df05c9c2391736f6b4eb20ab5b761f9de16a2b67e54e564c85d9e095"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/nautelle-runner-0.17.0-darwin-x64.tar.gz"
      sha256 "d7cd33b73ee3cc00434ffa190d75d40bb45185f102824d0485ceaeeb1766cb9e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/nautelle-runner-0.17.0-linux-arm64.tar.gz"
      sha256 "a4ae8350ecd38303289418524820a743ea37063fb999c700a57269626648a692"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/nautelle-runner-0.17.0-linux-x64.tar.gz"
      sha256 "bcfa433f79193792dd4a999f45c44126b991174d1ff3e0fefb7d49324655cadb"
    end
  end

  # SHA256SUMS of the release and its Ed25519 signature (ADR-0049).
  resource "SHA256SUMS" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/SHA256SUMS"
    sha256 "08ef4ac777584a3fd0281d182fe13f761e23f311a3ee3b4093a029fc7357a233"
  end

  resource "SHA256SUMS.sig" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.17.0/SHA256SUMS.sig"
    sha256 "02f0b1a5532306f6ed90467ddee342c0898231766779e8dbfb91c07bf2049b5c"
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
