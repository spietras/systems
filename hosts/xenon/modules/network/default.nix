# Network configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    # Disable dhcpcd, we use NetworkManager which has its own DHCP client
    dhcpcd = {
      enable = false;
    };

    hostId = config.constants.network.hostId;
    hostName = config.constants.name;

    # We use stubby as a local DNS resolver, so we need to point to it
    nameservers = [
      "127.0.0.1"
      "::1"
    ];

    # Use NetworkManager to manage network connections
    networkmanager = {
      dispatcherScripts = [
        # Change chrony servers states based on connection status
        {
          source = pkgs.substituteAll {
            src = ./chrony-online-offline.sh;

            chronyc = "${pkgs.chrony}/bin/chronyc";
          };
        }

        # Add DHCP-provided NTP servers to chrony
        {
          source = pkgs.substituteAll {
            src = ./chrony-dhcp-ntp.sh;

            chronyc = "${pkgs.chrony}/bin/chronyc";
            sourcedir = "dhcp";
          };
        }
      ];

      # Use systemd-resolved as the system DNS resolver
      dns = "systemd-resolved";

      enable = true;

      wifi = {
        # Use iwd instead of wpa_supplicant
        # It's faster for establishing connections
        backend = "iwd";
      };
    };

    # Disable default NTP servers
    timeServers = [];

    wireless = {
      iwd = {
        enable = true;
      };
    };
  };

  services = {
    # Use chrony as the NTP client
    chrony = {
      enable = true;

      # First pool is from ntp.org, which is probably the most reliable
      # Second pool is from Cloudflare, which is also great and supports NTS
      # But you can't connect to the second one on some networks
      # So we need to use 'authselectmode ignore' to not rely only on NTS
      # Also we provide the directory for DHCP-provided NTP servers
      extraConfig = ''
        pool pool.ntp.org iburst
        pool time.cloudflare.com iburst nts

        authselectmode ignore
        sourcedir /var/run/chrony/dhcp
      '';
    };

    # Use systemd-resolved as the system DNS resolver
    resolved = {
      enable = true;
    };

    # Use stubby as a local DNS resolver
    stubby = {
      enable = true;

      # For some reason, this is not the default, so we need to set it manually
      settings = pkgs.stubby.passthru.settingsExample;
    };

    # Disable systemd-timesyncd, we use chrony
    timesyncd = {
      enable = false;
    };
  };
}
