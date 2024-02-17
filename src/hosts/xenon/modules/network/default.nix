# Network configuration
{
  config,
  pkgs,
  ...
}: let
  yamlFormat = pkgs.formats.yaml {};
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
in {
  environment = {
    persistence = {
      "/softstate" = {
        directories = [
          # Network connections
          "/etc/NetworkManager/system-connections/"
        ];
      };
    };
  };

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

    hostId = config.constants.network.hostId;
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
          source = pkgs.substituteAll {
            src = ./chrony-online-offline.sh;

            chronyc = "${pkgs.chrony}/bin/chronyc";
            printf = "${pkgs.coreutils}/bin/printf";
          };
        }

        # Add DHCP-provided NTP servers to chrony
        {
          source = pkgs.substituteAll {
            src = ./chrony-dhcp-ntp.sh;

            chmod = "${pkgs.coreutils}/bin/chmod";
            chown = "${pkgs.coreutils}/bin/chown";
            chronyc = "${pkgs.chrony}/bin/chronyc";
            mkdir = "${pkgs.coreutils}/bin/mkdir";
            printf = "${pkgs.coreutils}/bin/printf";
            sourcedir = "dhcp";
            touch = "${pkgs.coreutils}/bin/touch";
            tr = "${pkgs.coreutils}/bin/tr";
            wc = "${pkgs.coreutils}/bin/wc";
          };
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

            clientId = config.sops.secrets."tailscale/clientId".path;
            clientSecret = config.sops.secrets."tailscale/clientSecret".path;
            curl = "${pkgs.curl}/bin/curl";
            ip = config.constants.network.tailscale.ip;
            jq = "${pkgs.jq}/bin/jq";
            mktemp = "${pkgs.coreutils}/bin/mktemp";
            rm = "${pkgs.coreutils}/bin/rm";
            tailscale = "${pkgs.tailscale}/bin/tailscale";
            xargs = "${pkgs.findutils}/bin/xargs";
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
