# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.2.0/agentdock-runner-0.2.0-darwin-arm64.tar.gz"
      sha256 "5c8e5e3d7d17667fa104478afce9949148d18aa82fb6ac6717c2731c59a93341"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.2.0/agentdock-runner-0.2.0-darwin-x64.tar.gz"
      sha256 "1ae9137fa06c7b5710c8dd54a9e858762bf213e012bc01c00430d7a861bb3e40"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.2.0/agentdock-runner-0.2.0-linux-arm64.tar.gz"
      sha256 "4f651bc4cfce0bf6d86731c5142d122fab0a255afc8c681c7efbabda998f8dc9"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.2.0/agentdock-runner-0.2.0-linux-x64.tar.gz"
      sha256 "3b0f0a88ad520045779f6c52a22ae870a406565c3a8d4e083be6cd376e84d6e8"
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
