# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.12.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.2/agentdock-runner-0.12.2-darwin-arm64.tar.gz"
      sha256 "2ba34f13f0e57a55ce5b48f4d9a990fff59b78b9e52122267dbf4b43eadd2dc2"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.2/agentdock-runner-0.12.2-darwin-x64.tar.gz"
      sha256 "c60e7c885b0145d3a2cccf52177c0362bd61202eba2a77f93e65b757c56b14bf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.2/agentdock-runner-0.12.2-linux-arm64.tar.gz"
      sha256 "c5cefac81d956b7a167fccf236ef7b085acf47461ffd3b69a0574b918b1f4b62"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.12.2/agentdock-runner-0.12.2-linux-x64.tar.gz"
      sha256 "913c995be5a60f22579ac3c96791a93be1115138f5f80d3f5ab04c6dbde5d60e"
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
