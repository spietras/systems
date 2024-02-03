# Network configuration
{
  config,
  pkgs,
  ...
}: {
  networking = {
    dhcpcd = {
      # Disable dhcpcd, we use NetworkManager which has its own DHCP client
      enable = false;
    };

    firewall = {
      trustedInterfaces = [
        # Allow traffic from Tailscale
        config.services.tailscale.interfaceName
      ];
    };

    hostId = config.constants.network.hostId;
    hostName = config.constants.name;

    # We use stubby as a local DNS resolver, so we need to point to it
    nameservers = [
      "127.0.0.1"
      "::1"
    ];

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

      # Use NetworkManager to manage network connections
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
        # Enable wireless networking
        enable = true;
      };
    };
  };

  services = {
    chrony = {
      # Use chrony as the NTP client
      enable = true;

      extraConfig = ''
        # ntp.org is probably the most reliable NTP server
        pool pool.ntp.org iburst

        # Cloudflare is also great and supports NTS
        pool time.cloudflare.com iburst nts

        # Use NTS only as a fallback, because it's not reliable on some networks
        authselectmode ignore

        # Also use DHCP-provided NTP servers
        sourcedir /var/run/chrony/dhcp/
      '';
    };

    resolved = {
      # Use systemd-resolved as the system DNS resolver
      enable = true;
    };

    stubby = {
      # Use stubby as a local DNS resolver
      enable = true;

      # For some reason, this is not the default, so we need to set it manually
      settings = pkgs.stubby.passthru.settingsExample;
    };

    tailscale = {
      # Use tailscale for networking between machines
      enable = true;

      # Pick port at random
      port = 0;
    };

    timesyncd = {
      # Disable systemd-timesyncd, we use chrony
      enable = false;
    };
  };

  systemd = {
    services = {
      # Logout from Tailscale network on shutdown
      tailscale-logout = {
        after = [
          # Run after network is online
          "network-online.target"

          # Run after tailscale daemon is running
          "tailscaled.service"
        ];

        description = "Automatic logout from Tailscale";

        requires = [
          # Require network to be online
          "network-online.target"

          # Require tailscale daemon to be running
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

        wantedBy = [
          # Make available at startup
          "multi-user.target"
        ];
      };

      # Autoconnect to Tailscale network with authentication key
      tailscale-up = {
        after = [
          # Run after network is online
          "network-online.target"

          # Run after tailscale daemon is running
          "tailscaled.service"
        ];

        description = "Automatic connection to Tailscale";

        requires = [
          # Require network to be online
          "network-online.target"

          # Require tailscale daemon to be running
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

        wantedBy = [
          # Run at startup
          "multi-user.target"
        ];
      };
    };
  };
}
