# Rendered from AgentDock's apps/runner/homebrew/agentdock-runner.rb.template
# by apps/runner/scripts/render-formula.sh on every runner release (ADR-0017).
# Change the template there, not this file.
class AgentdockRunner < Formula
  desc "Per-machine daemon of AgentDock, a control plane for agent fleets"
  homepage "https://agentdock.luna-realm.com/"
  version "0.10.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.10.0/agentdock-runner-0.10.0-darwin-arm64.tar.gz"
      sha256 "74880b91cdae12b0b8c4503f66255bf8e91febcf02e66aff8c306f25c5aba119"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.10.0/agentdock-runner-0.10.0-darwin-x64.tar.gz"
      sha256 "9ae76a975783f123a2862471eb2a0fb19f431ba92b2a8a2c7fc7275057b215c8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.10.0/agentdock-runner-0.10.0-linux-arm64.tar.gz"
      sha256 "a51be12001630750af8b67d3eee83a969b0da16ad89007d92cf4663ce310f790"
    end
    on_intel do
      url "https://github.com/AndreyBegma/AgentDock/releases/download/runner-v0.10.0/agentdock-runner-0.10.0-linux-x64.tar.gz"
      sha256 "1ca384bdefa52adc9337cbfb46382c222aa0744f6276ce020440d3df3926bc3d"
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
