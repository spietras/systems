# Reusable constants are defined here
# All options have default values
# You can use these options in other modules
{lib, ...}: {
  options = {
    constants = {
      name = lib.mkOption {
        default = "carbon";
        description = "Name of the machine";
        type = lib.types.str;
      };

      network = {
        domain = {
          root = lib.mkOption {
            default = "spietras.dev";
            description = "Root domain that I own";
            type = lib.types.str;
          };

          subdomains = {
            tailscale = lib.mkOption {
              default = "ts";
              description = "Subdomain for Tailscale";
              type = lib.types.str;
            };
          };
        };

        hostId = lib.mkOption {
          default = "bc24e266";
          description = "Unique identifier for the machine";
          type = lib.types.str;
        };

        tailscale = {
          ip = lib.mkOption {
            default = "100.86.6.103";
            description = "IP address of the machine in the Tailscale network";
            type = lib.types.str;
          };

          routes = lib.mkOption {
            default = [];
            description = "List of routes to advertise in the Tailscale network";
            type = lib.types.listOf lib.types.str;
          };

          tailnet = lib.mkOption {
            default = "mermaid-vibe";
            description = "Name of the Tailscale network";
            type = lib.types.str;
          };
        };
      };

      platform = lib.mkOption {
        default = "x86_64-linux";
        description = "Platform of the machine";
        type = lib.types.str;
      };

      secrets = {
        sops = {
          age = {
            file = lib.mkOption {
              default = "/var/lib/sops/age/keys.txt";
              description = "Path to the file with private age keys";
              type = lib.types.str;
            };
          };
        };
      };

      storage = {
        disks = {
          main = {
            device = lib.mkOption {
              default = "/dev/disk/by-id/nvme-Micron_3400_MTFDKBA512TFH_213230D6F1EE";
              description = "Device path of the main disk";
              type = lib.types.str;
            };
          };
        };
      };

      vm = {
        name = lib.mkOption {
          default = "carbon-vm";
          description = "Name of the virtual machine";
          type = lib.types.str;
        };

        network = {
          hostId = lib.mkOption {
            default = "2b221d4f";
            description = "Unique identifier for the virtual machine";
            type = lib.types.str;
          };

          tailscale = {
            ip = lib.mkOption {
              default = "100.86.7.103";
              description = "IP address of the machine in the Tailscale network";
              type = lib.types.str;
            };

            routes = lib.mkOption {
              default = [];
              description = "List of routes to advertise in the Tailscale network";
              type = lib.types.listOf lib.types.str;
            };
          };
        };

        resources = {
          cpu = {
            cores = lib.mkOption {
              default = 4;
              description = "Number of CPU cores";
              type = lib.types.int;
            };
          };

          disk = {
            size = lib.mkOption {
              default = 32768;
              description = "Size of the disk in MB";
              type = lib.types.int;
            };
          };

          memory = {
            size = lib.mkOption {
              default = 8192;
              description = "Size of the memory in MB";
              type = lib.types.int;
            };
          };
        };
      };
    };
  };
}
