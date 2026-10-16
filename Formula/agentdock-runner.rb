# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.12.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.1/agentdock-runner-0.12.1-darwin-arm64.tar.gz"
      sha256 "febb15ec138de24a00fbf98bf89bd83e080c6a36b04dbcb60dac336075225dfc"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.1/agentdock-runner-0.12.1-darwin-x64.tar.gz"
      sha256 "766f0724f595422962bdb461e55ad8e86144f031be441eb20215b05dd23821d9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.1/agentdock-runner-0.12.1-linux-arm64.tar.gz"
      sha256 "096910a88043709cca2a686ea75c99afa1f66520b2556337abf40de86aa01e0a"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.1/agentdock-runner-0.12.1-linux-x64.tar.gz"
      sha256 "23cbe06ed014ed53977811e472f99e2a6cc393a3d8bbdf12505b5800d79ff895"
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
