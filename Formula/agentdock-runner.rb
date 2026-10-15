# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.9.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.1/agentdock-runner-0.9.1-darwin-arm64.tar.gz"
      sha256 "b5e40d7fb37cd6fd0825fa9eef7f3c69b113fc8971ccf46e14f61b5538154220"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.1/agentdock-runner-0.9.1-darwin-x64.tar.gz"
      sha256 "f0580bb688844e4ffca82447ef4fc939295c538d76a38be68b407a00807761dc"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.1/agentdock-runner-0.9.1-linux-arm64.tar.gz"
      sha256 "ba11052a2ff65a7a4bf851038896a1f803d21a20e95eeea366fc3de6f778d641"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.1/agentdock-runner-0.9.1-linux-x64.tar.gz"
      sha256 "95be6600b8f94185a2c2d2b1483af789a354614f6220feab11eabec983e91cdf"
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
