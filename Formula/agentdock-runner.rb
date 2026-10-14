# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.3.0/agentdock-runner-0.3.0-darwin-arm64.tar.gz"
      sha256 "0b5e659e30a7be3fa1d189edfa9ba960ca4fc63784e697ef6d209db428dafd46"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.3.0/agentdock-runner-0.3.0-darwin-x64.tar.gz"
      sha256 "d370391c03dfa49826291375c3587ba931a5db043f19ee086aa03c90f3ad84ee"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.3.0/agentdock-runner-0.3.0-linux-arm64.tar.gz"
      sha256 "f3303cecb0bd7b41e8fb6f7104fc1f252b765235c35d01c4298215b7e38c7452"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.3.0/agentdock-runner-0.3.0-linux-x64.tar.gz"
      sha256 "552c857d7741b07e86705c7453c0146956f841f22048810b30875c42125d5c71"
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
