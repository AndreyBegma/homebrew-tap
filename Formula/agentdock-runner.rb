# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.5.0/agentdock-runner-0.5.0-darwin-arm64.tar.gz"
      sha256 "f12dee2fcb79f4931e3e1bdbeef5ed02e1b1669148bfd79780d4c9ca32b3a5bf"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.5.0/agentdock-runner-0.5.0-darwin-x64.tar.gz"
      sha256 "118ad4585d80937d7b9a2ccd02cb2d314e0aa692cd5eb5754f4ac94cebb916fb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.5.0/agentdock-runner-0.5.0-linux-arm64.tar.gz"
      sha256 "299ec878829c2c2803e4aa9e2fcc0e45e08591000ec29370695f609a9d3d703b"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.5.0/agentdock-runner-0.5.0-linux-x64.tar.gz"
      sha256 "4b1e6af37f93f91b7ac0efdd9342513db9a5cab5c7a740fcdeacd18a43c93053"
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
