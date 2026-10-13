# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://github.com/AndreyBegma/AgentDock"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.1.0/agentdock-runner-0.1.0-darwin-arm64.tar.gz"
      sha256 "f1d18a55490cbbb4e9864e6ecb7175509019da365dad8ba9a59a153103a43961"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.1.0/agentdock-runner-0.1.0-darwin-x64.tar.gz"
      sha256 "76be07bb54266bb18186fef19d743e50fd182c8d14a278c174c6245bde57031c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.1.0/agentdock-runner-0.1.0-linux-arm64.tar.gz"
      sha256 "09eae5309ece427ee163353263f6f3bdd07b378678062eb617ba8705dec4f195"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.1.0/agentdock-runner-0.1.0-linux-x64.tar.gz"
      sha256 "a496021d7ba2d412497e7069e43d884032e35f7d04fa96d6ec1777ed1e8587ca"
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
