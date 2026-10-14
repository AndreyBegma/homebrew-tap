# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.4.0/agentdock-runner-0.4.0-darwin-arm64.tar.gz"
      sha256 "2c85e0490c4a184b8d4828dfe511c1c7d8d34a33e4ab54781cb8ce5454e842e0"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.4.0/agentdock-runner-0.4.0-darwin-x64.tar.gz"
      sha256 "fe711dfc98aa2ba6bf4ef50812cd3c1fd9f8ab90935522a195462b8f643c4497"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.4.0/agentdock-runner-0.4.0-linux-arm64.tar.gz"
      sha256 "29754f7e7d129d9a2ce781d0c2ede98e752d6627298f8cffe6dccf2a7ea8a244"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.4.0/agentdock-runner-0.4.0-linux-x64.tar.gz"
      sha256 "203361888227da7bde28c927db39db1a010ba4a26b630ac6eb7d5dc3d965a982"
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
