# Rendered from Nautelle's apps/runner/homebrew/nautelle-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
require "digest"
require "openssl"

class NautelleRunner < Formula
  desc "Per-machine daemon of Nautelle, a control plane for agent fleets"
  homepage "https://nautelle.luna-realm.com/"
  version "0.18.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/nautelle-runner-0.18.0-darwin-arm64.tar.gz"
      sha256 "3563021ee022e8982fa825dd431b7921e1ea73ae3f0e5f59fc88a560bc2c9a84"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/nautelle-runner-0.18.0-darwin-x64.tar.gz"
      sha256 "7d555bb0e7b8c20f92bc914ba953a414f14b40bd0c714f128e9b5ce4dd2f1624"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/nautelle-runner-0.18.0-linux-arm64.tar.gz"
      sha256 "35043a8a1b9b959d97bd80978b02070253ff9cfd2376231f74b06a10287ef285"
    end
    on_intel do
      url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/nautelle-runner-0.18.0-linux-x64.tar.gz"
      sha256 "c51cd6440b5451a10db4ffac91d89bb27cebd99efd8147bb65eef427959ed2c3"
    end
  end

  # SHA256SUMS of the release and its Ed25519 signature (ADR-0049).
  resource "SHA256SUMS" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/SHA256SUMS"
    sha256 "4741e489d7e32124d53df89aa3838974b8878e59951a992bb834ff3fe9bbe259"
  end

  resource "SHA256SUMS.sig" do
    url "https://github.com/AndreyBegma/Nautelle/releases/download/runner-v0.18.0/SHA256SUMS.sig"
    sha256 "bac8f340f1de63dd5035966a3c05a198bf0135a6e11e552fb9eac0b60aec55df"
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
