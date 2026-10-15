# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.7.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.1/agentdock-runner-0.7.1-darwin-arm64.tar.gz"
      sha256 "d67beaaecfd55f90d28192870cec783db28bd5c40fa283d20c63bb88e60f898c"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.1/agentdock-runner-0.7.1-darwin-x64.tar.gz"
      sha256 "c5d933183c08065429be7d9d6f1c0ff9c3c65da92a1710978032047010851b4d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.1/agentdock-runner-0.7.1-linux-arm64.tar.gz"
      sha256 "40b4bc59c37be16d4792973df1e6cddeedd5b0245cc68c04b76d11f1f2f9ea5f"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.1/agentdock-runner-0.7.1-linux-x64.tar.gz"
      sha256 "ad5d019d819147e9c1d7ee19ffed6e22754f27349db767f12d2336df682d4459"
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
