# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.8.0/agentdock-runner-0.8.0-darwin-arm64.tar.gz"
      sha256 "ca7847e7d8bceb6b4bd7922a5bf4fdab681a5c6494a57372b4e84e4fb4095b17"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.8.0/agentdock-runner-0.8.0-darwin-x64.tar.gz"
      sha256 "2898195bfe9e40e1a3a2a0b5661bbd31c56ea267f8b3a542604ea4e1996c1bb5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.8.0/agentdock-runner-0.8.0-linux-arm64.tar.gz"
      sha256 "393c482d9fb75c2e40f2d554bff82f819b54ac5c29775dfad6d0da3aad8448eb"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.8.0/agentdock-runner-0.8.0-linux-x64.tar.gz"
      sha256 "e8b1f83e2db8e64d37a6f2dd35bfb51ce91e59795ae960510b74fde70df5ce45"
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
