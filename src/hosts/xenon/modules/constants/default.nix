# Reusable constants are defined here
# All options have default values
# You can use these options in other modules
{
  config,
  lib,
  ...
}: {
  options = {
    constants = {
      kubernetes = {
        cluster = {
          name = lib.mkOption {
            default = "main";
            description = "Name of the Kubernetes cluster";
            type = lib.types.str;
          };
        };

        directories = {
          state = lib.mkOption {
            default = "/var/lib/kubernetes/k3s/";
            description = "Directory to store state in";
            type = lib.types.path;
          };
        };

        files = {
          kubeconfig = lib.mkOption {
            default = "/etc/kubernetes/kubeconfig.yaml";
            description = "File to store the kubeconfig in";
            type = lib.types.path;
          };
        };

        flux = {
          source = {
            branch = lib.mkOption {
              default = "main";
              description = "Branch of the Git repository";
              type = lib.types.str;
            };

            ignore = lib.mkOption {
              default = "";
              description = "Paths to ignore in the repository";
              type = lib.types.str;
            };

            path = lib.mkOption {
              default = "src/clusters/${config.constants.kubernetes.cluster.name}";
              description = "Path to the directory with manifests";
              type = lib.types.str;
            };

            url = lib.mkOption {
              default = "https://github.com/spietras/clusters";
              description = "URL of the Git repository";
              type = lib.types.str;
            };
          };
        };

        network = {
          addresses = {
            cluster = lib.mkOption {
              default = "10.42.0.0/16";
              description = "IP address allocation range for pods";
              type = lib.types.str;
            };

            service = lib.mkOption {
              default = "10.43.0.0/16";
              description = "IP address allocation range for services";
              type = lib.types.str;
            };
          };

          interfaces = {
            cni = lib.mkOption {
              default = "cni0";
              description = "Name of the CNI interface";
              type = lib.types.str;
            };
          };

          ports = {
            api = lib.mkOption {
              default = 6443;
              description = "Port for API server";
              type = lib.types.int;
            };
          };
        };

        resources = {
          reserved = {
            system = {
              cpu = lib.mkOption {
                default = "500m";
                description = "Reserved CPU for system";
                type = lib.types.str;
              };

              memory = lib.mkOption {
                default = "500Mi";
                description = "Reserved memory for system";
                type = lib.types.str;
              };

              pid = lib.mkOption {
                default = 100;
                description = "Reserved number of process IDs for system";
                type = lib.types.int;
              };

              storage = lib.mkOption {
                default = "5Gi";
                description = "Reserved storage for system";
                type = lib.types.str;
              };
            };
          };
        };
      };

      name = lib.mkOption {
        default = "xenon";
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
          default = "9f86d081";
          description = "Unique identifier for the machine";
          type = lib.types.str;
        };

        tailscale = {
          ip = lib.mkOption {
            default = "100.127.131.11";
            description = "IP address of the machine in the Tailscale network";
            type = lib.types.str;
          };

          routes = lib.mkOption {
            default = [config.constants.kubernetes.network.addresses.cluster];
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
              default = "/dev/disk/by-id/ata-TEAM_T253240GB_TPBF2209020010203322";
              description = "Device path of the main disk";
              type = lib.types.str;
            };
          };
        };
      };

      vm = {
        cpu = {
          cores = lib.mkOption {
            default = 4;
            description = "Number of CPU cores";
            type = lib.types.int;
          };
        };

        disk = {
          size = lib.mkOption {
            default = 8192;
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

        name = lib.mkOption {
          default = "xenon-vm";
          description = "Name of the virtual machine";
          type = lib.types.str;
        };

        network = {
          hostId = lib.mkOption {
            default = "cc4e8be2";
            description = "Unique identifier for the virtual machine";
            type = lib.types.str;
          };

          tailscale = {
            ip = lib.mkOption {
              default = "100.127.132.11";
              description = "IP address of the machine in the Tailscale network";
              type = lib.types.str;
            };
          };
        };
      };
    };
  };
}
