# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.9.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.2/agentdock-runner-0.9.2-darwin-arm64.tar.gz"
      sha256 "9e31861b209605f18042962ed9fd3f2e6e42e0aa625b27378be314ee98030ecd"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.2/agentdock-runner-0.9.2-darwin-x64.tar.gz"
      sha256 "52c4606aaa007e9c18ef9e27005f86a4d6f3e6e0eebd2ccb6464381cc0ed300e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.2/agentdock-runner-0.9.2-linux-arm64.tar.gz"
      sha256 "721b0b13643bd29384b1c01414e9c38c50b09b4328ab44b0ac14dcb6ec85e684"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.2/agentdock-runner-0.9.2-linux-x64.tar.gz"
      sha256 "8faf9597a5ac7f0cd8a755790e8a32e1b0d847816369dceda65a4c55baac72eb"
    end
  end

  def install
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
