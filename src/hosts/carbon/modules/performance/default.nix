# Things that impact performance
{
  services = {
    dbus = {
      # dbus-broker is supposed to be faster than the default dbus-daemon
      implementation = "broker";
    };

    earlyoom = {
      # Enable earlyoom as the user-space OOM killer
      # Compared to systemd-oomd, earlyoom can kill individual processes instead of the whole cgroup
      # Compared to nohang, earlyoom is more lightweight
      enable = true;
    };

    irqbalance = {
      # Distribute interrupts across CPUs
      enable = true;
    };

    logind = {
      settings = {
        Login = {
          # Kill user processes when the user logs out
          # This is useful for reducing unnecessary memory usage
          # However, sometimes you need to keep some processes running even after logging out
          # For example, when using screen or tmux
          # In this case, you need to run them with systemd-run --user
          KillUserProcesses = true;
        };
      };
    };
  };

  systemd = {
    oomd = {
      # Disable systemd-oomd
      enable = false;
    };
  };
}
