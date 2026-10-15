# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.6.0/agentdock-runner-0.6.0-darwin-arm64.tar.gz"
      sha256 "d5742946caf97847c2a729b746e42770f49e67f543d704655287f4088ebd86ab"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.6.0/agentdock-runner-0.6.0-darwin-x64.tar.gz"
      sha256 "17b0c3cda6ed55c1e53832e6dfda2fcaa7209a187a10e2f2d0ab782189996dec"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.6.0/agentdock-runner-0.6.0-linux-arm64.tar.gz"
      sha256 "c383789db4076c04b80b514af6e4eaae71e60b676a09b08aa51787698a10410f"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.6.0/agentdock-runner-0.6.0-linux-x64.tar.gz"
      sha256 "26af05a55f92dde4bad4892ccdd2e57243a922f28aa4fbbbec173d9d9b0eecd7"
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
