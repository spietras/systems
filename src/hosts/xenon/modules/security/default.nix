# Things related to security
{config, ...}: {
  networking = {
    firewall = {
      # Enable the firewall
      enable = true;

      # Limit the number of pings allowed to prevent ping flooding
      pingLimit = "--limit 10/s --limit-burst 100";

      # Reject bad packets instead of dropping them
      rejectPackets = true;

      trustedInterfaces = [
        # Allow traffic from Tailscale
        config.services.tailscale.interfaceName
      ];
    };

    tcpcrypt = {
      # Use tcpcrypt to encrypt TCP connections when possible
      enable = true;
    };
  };

  security = {
    # Disable modifiying kernel image after boot
    protectKernelImage = true;

    rtkit = {
      # Enable permissions for realtime scheduling
      enable = true;
    };

    sudo = {
      # Only users in wheel group can use sudo
      execWheelOnly = true;

      # But they don't need to enter a password
      wheelNeedsPassword = false;
    };
  };

  users = {
    groups = {
      # We need to create a group for tcpcryptd
      # For some reason it's not created automatically
      tcpcryptd = {
      };
    };

    users = {
      tcpcryptd = {
        # tcpcryptd user is actually created automatically, but we need to assign it to a group
        group = "tcpcryptd";

        isSystemUser = true;
      };
    };
  };
}
