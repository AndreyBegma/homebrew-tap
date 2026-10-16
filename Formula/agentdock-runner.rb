# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.0/agentdock-runner-0.12.0-darwin-arm64.tar.gz"
      sha256 "41f1384e8319b280fb31082d9ef50ec5c41f0241f17d308219b10c2e7532a4af"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.0/agentdock-runner-0.12.0-darwin-x64.tar.gz"
      sha256 "7f6a6df6bf87d589ef22eacb7ea05127243d5733af18fa065dd7433c6448f740"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.0/agentdock-runner-0.12.0-linux-arm64.tar.gz"
      sha256 "d7851bc45c96a192113e49ec6bff1408a9e17421ff062c787c9be04211712dc4"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.0/agentdock-runner-0.12.0-linux-x64.tar.gz"
      sha256 "42a5c290844b7f3f6e015e1518cf1da94dcfbd563a896b7ea79e3415ec90d925"
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
