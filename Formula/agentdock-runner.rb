# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.0/agentdock-runner-0.7.0-darwin-arm64.tar.gz"
      sha256 "eca68ac765df2ce43dc93e0429a16a09c09e193a8db2532c015bdf5cd9d7823a"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.0/agentdock-runner-0.7.0-darwin-x64.tar.gz"
      sha256 "4d3e08de7bcbadda7a126fd61022c7180cadc79c02abcd507462ab5381d66cb8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.0/agentdock-runner-0.7.0-linux-arm64.tar.gz"
      sha256 "e39005c6f4180b6fae77c10839d06e3e49eb15c37c2dfa647a72849d0e582874"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.7.0/agentdock-runner-0.7.0-linux-x64.tar.gz"
      sha256 "5b6aae5340902ae405b3b484841448b94f32fba5c499b18edfef8e65262246ae"
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
