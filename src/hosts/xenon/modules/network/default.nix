# Network configuration
{
  config,
  pkgs,
  ...
}: let
  yamlFormat = pkgs.formats.yaml {};
  chronyOnlineOfflineScript = pkgs.writeShellApplication {
    # Name of the script
    name = "chrony-online-offline";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils pkgs.chrony];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./chrony-online-offline.sh;
      }
    );
  };
  chronyDHCPNTPScript = pkgs.writeShellApplication {
    # Name of the script
    name = "chrony-dhcp-ntp";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils pkgs.chrony];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./chrony-dhcp-ntp.sh;

        # Provide values to substitute
        sourcedir = "dhcp";
      }
    );
  };
  dnsproxyConfig = yamlFormat.generate "dnsproxy.yaml" {
    # Query upstream DNS servers in parallel
    all-servers = true;

    bootstrap = [
      # Use Cloudflare DNS
      "1.1.1.1:53"

      # Use Google DNS
      "8.8.8.8:53"
    ];

    # Cache DNS responses
    cache = true;

    fallback = [
      # Use Cloudflare DNS over TLS
      "1.1.1.1:853"

      # Use Google DNS over TLS
      "8.8.8.8:853"
    ];

    # Enable HTTP/3 support
    http3 = true;

    listen-addrs = [
      # Listen on loopback IPv4 interface
      "127.0.0.1"

      # Listen on loopback IPv6 interface
      "::1"
    ];

    listen-ports = [
      # Listen on port 53 for DNS
      53
    ];

    # Log to a file
    output = "/var/log/dnsproxy/dnsproxy.log";

    upstream = [
      # Use Cloudflare DNS over HTTPS
      "https://cloudflare-dns.com/dns-query"

      # Use Google DNS over HTTPS
      "https://dns.google/dns-query"
    ];
  };
  tailscaleLogoutScript = pkgs.writeShellApplication {
    # Name of the script
    name = "tailscale-logout";

    # Packages available in the script
    runtimeInputs = [pkgs.tailscale];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./tailscale-logout.sh;
      }
    );
  };
  tailscaleUpScript = pkgs.writeShellApplication {
    # Name of the script
    name = "tailscale-up";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils pkgs.curl pkgs.findutils pkgs.jq pkgs.tailscale];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./tailscale-up.sh;

        clientId = config.sops.secrets."tailscale/clientId".path;
        clientSecret = config.sops.secrets."tailscale/clientSecret".path;
        ip = config.constants.network.tailscale.ip;
      }
    );
  };
in {
  networking = {
    dhcpcd = {
      # Disable dhcpcd, we use NetworkManager which has its own DHCP client
      enable = false;
    };

    firewall = {
      trustedInterfaces = [
        # Allow all traffic on Tailscale interface
        config.services.tailscale.interfaceName
      ];
    };

    # The identifier of the machine
    hostId = config.constants.network.hostId;

    # The hostname of the machine
    hostName = config.constants.name;

    # We use dnsproxy as a local DNS resolver, so we need to point to it
    nameservers = [
      "127.0.0.1"
      "::1"
    ];

    networkmanager = {
      dispatcherScripts = [
        # Change chrony servers states based on connection status
        {
          source = "${chronyOnlineOfflineScript}/bin/chrony-online-offline";
        }

        # Add DHCP-provided NTP servers to chrony
        {
          source = "${chronyDHCPNTPScript}/bin/chrony-dhcp-ntp";
        }
      ];

      # Push DNS configuration to systemd-resolved
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

      extraConfig = ''
        # Disable default listener on port 53 on loopback interface
        DNSStubListener=no

        # Listen for DNS requests on Tailscale interface
        # Port 53 is used for that
        # Both TCP and UDP requests are accepted
        DNSStubListenerExtra=${config.constants.network.tailscale.ip}
      '';
    };

    tailscale = {
      # Use tailscale for networking between machines
      enable = true;

      # Allow traffic on Tailscale port
      openFirewall = true;
    };

    timesyncd = {
      # Disable systemd-timesyncd, we use chrony
      enable = false;
    };
  };

  systemd = {
    services = {
      # Run dnsproxy as a local DNS resolver
      dnsproxy = {
        after = [
          # Run after connecting to Tailscale
          "tailscale-up.service"
        ];

        before = [
          # Run before name resolution
          "nss-lookup.target"
        ];

        description = "Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support";

        requires = [
          # Require Tailscale connection
          "tailscale-up.service"
        ];

        serviceConfig = {
          # Allow binding to privileged ports
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";

          # Allow binding to privileged ports
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";

          # Run as a user specific to the service
          DynamicUser = true;

          # Run dnsproxy
          ExecStart = "${pkgs.dnsproxy}/bin/dnsproxy --config-path=${dnsproxyConfig}";

          # Create directory for logs
          LogsDirectory = "dnsproxy";

          # Restart always
          Restart = "always";

          # Run as a daemon
          Type = "simple";
        };

        wantedBy = [
          # Make available at startup
          "multi-user.target"
        ];
      };

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
        preStop = "${tailscaleLogoutScript}/bin/tailscale-logout";

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

        script = "${tailscaleUpScript}/bin/tailscale-up";

        wantedBy = [
          # Run at startup
          "multi-user.target"
        ];
      };
    };
  };
}
