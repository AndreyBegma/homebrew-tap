# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.11.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.2/agentdock-runner-0.11.2-darwin-arm64.tar.gz"
      sha256 "006ebd46413fa0c18acded28259ebbf536bbc22c27266d410f84cc47c6e2e919"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.2/agentdock-runner-0.11.2-darwin-x64.tar.gz"
      sha256 "36ef39e1be6f58db42a909f1e6141b13fe168356e658f6e20e2f56ae926bc3d7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.2/agentdock-runner-0.11.2-linux-arm64.tar.gz"
      sha256 "ca4a3b8b481f6b6ae6a9e184b8e1e7a263854abcd9637e54cd6238f89e641d11"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.2/agentdock-runner-0.11.2-linux-x64.tar.gz"
      sha256 "19ca2e7d44b664fe2b87365bea0ec6216a99010a8c513e1956052600073edf04"
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
