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

    # Use tailscale for networking between machines
    tailscale = {
      enable = true;

      # Pick port at random
      port = 0;
    };

    # Disable systemd-timesyncd, we use chrony
    timesyncd = {
      enable = false;
    };
  };

  systemd = {
    services = {
      # Logout from Tailscale network on shutdown
      tailscale-logout = {
        # Run only after network is online and tailscale daemon is running
        after = [
          "network-online.target"
          "tailscaled.service"
        ];

        description = "Automatic logout from Tailscale";

        # Require network to be online and tailscale daemon to be running
        requires = [
          "network-online.target"
          "tailscaled.service"
        ];

        serviceConfig = {
          # Run only once at shutdown
          Type = "oneshot";

          # This is needed for some reason
          RemainAfterExit = "yes";
        };

        # Run when stopping the system
        preStop = builtins.readFile (
          pkgs.substituteAll {
            src = ./tailscale-logout.sh;

            tailscale = "${pkgs.tailscale}/bin/tailscale";
          }
        );

        # Make available at startup
        wantedBy = [
          "multi-user.target"
        ];
      };

      # Autoconnect to Tailscale network with authentication key
      tailscale-up = {
        # Run only after network is online and tailscale daemon is running
        after = [
          "network-online.target"
          "tailscaled.service"
        ];

        description = "Automatic connection to Tailscale";

        # Require network to be online and tailscale daemon to be running
        requires = [
          "network-online.target"
          "tailscaled.service"
        ];

        serviceConfig = {
          # Connect only once at startup
          Type = "oneshot";
        };

        script = builtins.readFile (
          pkgs.substituteAll {
            src = ./tailscale-up.sh;

            mktemp = "${pkgs.coreutils}/bin/mktemp";
            curl = "${pkgs.curl}/bin/curl";
            jq = "${pkgs.jq}/bin/jq";
            tailscale = "${pkgs.tailscale}/bin/tailscale";
            clientId = config.sops.secrets."tailscale/clientId".path;
            clientSecret = config.sops.secrets."tailscale/clientSecret".path;
          }
        );

        # Run at startup
        wantedBy = [
          "multi-user.target"
        ];
      };
    };
  };
}
