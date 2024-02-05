# Reusable constants are defined here
# All options have default values
# You can use them in other modules
{
  config,
  lib,
  ...
}: {
  options = {
    constants = {
      name = lib.mkOption {
        default = "xenon";
        description = "Name of the machine";
        type = lib.types.str;
      };

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
              default = "10.42.0.0/16,2001:cafe:42::/56";
              description = "IP address allocation range for pods";
              type = lib.types.str;
            };

            service = lib.mkOption {
              default = "10.43.0.0/16,2001:cafe:43::/112";
              description = "IP address allocation range for services";
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

              storage = lib.mkOption {
                default = "5Gi";
                description = "Reserved storage for system";
                type = lib.types.str;
              };

              pid = lib.mkOption {
                default = 100;
                description = "Reserved number of process IDs for system";
                type = lib.types.int;
              };
            };
          };
        };
      };

      network = {
        hostId = lib.mkOption {
          default = "9f86d081";
          description = "Unique identifier for the machine";
          type = lib.types.str;
        };
      };

      platform = lib.mkOption {
        default = "x86_64-linux";
        description = "Platform of the machine";
        type = lib.types.str;
      };

      storage = {
        diskPath = lib.mkOption {
          default = "/dev/sda";
          description = "Path to the disk";
          type = lib.types.path;
        };

        partitions = {
          boot = {
            label = lib.mkOption {
              default = "boot";
              description = "Label for the boot partition";
              type = lib.types.str;
            };
          };

          main = {
            datasets = {
              hardstate = {
                label = lib.mkOption {
                  default = "hardstate";
                  description = "Label for the hardstate dataset";
                  type = lib.types.str;
                };
              };

              home = {
                label = lib.mkOption {
                  default = "home";
                  description = "Label for the home dataset";
                  type = lib.types.str;
                };
              };

              nix = {
                label = lib.mkOption {
                  default = "nix";
                  description = "Label for the nix dataset";
                  type = lib.types.str;
                };
              };

              softstate = {
                label = lib.mkOption {
                  default = "softstate";
                  description = "Label for the softstate dataset";
                  type = lib.types.str;
                };
              };
            };

            label = lib.mkOption {
              default = "main";
              description = "Label for the main partition";
              type = lib.types.str;
            };
          };

          swap = {
            label = lib.mkOption {
              default = "swap";
              description = "Label for the swap partition";
              type = lib.types.str;
            };

            size = lib.mkOption {
              default = 16384;
              description = "Size of the swap partition in MB";
              type = lib.types.int;
            };
          };
        };
      };

      vm = {
        cores = lib.mkOption {
          default = 4;
          description = "Number of CPU cores";
          type = lib.types.int;
        };

        diskPath = lib.mkOption {
          default = "/dev/vda";
          description = "Path to the disk in the virtual machine";
          type = lib.types.path;
        };

        diskSize = lib.mkOption {
          default = 8192;
          description = "Size of the disk in MB";
          type = lib.types.int;
        };

        memorySize = lib.mkOption {
          default = 4096;
          description = "Size of the memory in MB";
          type = lib.types.int;
        };

        swapSize = lib.mkOption {
          default = 1024;
          description = "Size of the swap in MB";
          type = lib.types.int;
        };
      };
    };
  };
}
