# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.11.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.0/agentdock-runner-0.11.0-darwin-arm64.tar.gz"
      sha256 "191118b2c57559ba3cedd8c9e486bd640071db0fede29af9ba3af404b0a7ed11"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.0/agentdock-runner-0.11.0-darwin-x64.tar.gz"
      sha256 "05c0254b9f008384bdfc326f32d46502e959d5eb3a6684afad69906c0945cf10"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.0/agentdock-runner-0.11.0-linux-arm64.tar.gz"
      sha256 "ff03af2ad7059bda18229b68a35a135f9fc0666bbbcdbe01cbca87b278b91669"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.0/agentdock-runner-0.11.0-linux-x64.tar.gz"
      sha256 "065048fc3c6536dffd5b7358b7de9657643b85ffb9f0844c023dc0cbc6a17971"
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
