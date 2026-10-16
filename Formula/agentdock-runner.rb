# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.11.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.1/agentdock-runner-0.11.1-darwin-arm64.tar.gz"
      sha256 "1ab09c9b638da4c6f1de15503ccccd3c606eecc1a417884a2b866138a110ac3f"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.1/agentdock-runner-0.11.1-darwin-x64.tar.gz"
      sha256 "897a429c49e78b67a523970fa83a9e9b182c1c8ff020049efd83fcdf548c3539"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.1/agentdock-runner-0.11.1-linux-arm64.tar.gz"
      sha256 "af0c1ff85c457737d6a11ef5fa31818efa3ce54e051eaf9c70ef7e7d9ee69b05"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.11.1/agentdock-runner-0.11.1-linux-x64.tar.gz"
      sha256 "ca429dff958731d41a924022422778fb9e21aae8799882cf1ae897c7bf19ea62"
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
