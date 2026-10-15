# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.0/agentdock-runner-0.9.0-darwin-arm64.tar.gz"
      sha256 "9d1e0e56cb4bcb5b783346464a0370022ee65d15e68d459277d44a316e282b7e"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.0/agentdock-runner-0.9.0-darwin-x64.tar.gz"
      sha256 "c8993cbe3d42832ddcdeed402d482270f7a2c506a15741fd0b3ea79f985970ed"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.0/agentdock-runner-0.9.0-linux-arm64.tar.gz"
      sha256 "f7bea2d43b11bd2beb36400fb03a484f72762ee75ba54c0450e3547827541201"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.9.0/agentdock-runner-0.9.0-linux-x64.tar.gz"
      sha256 "806affe0121d92629c422d56bf402db811903424f09012bfdeafb963f546769e"
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
