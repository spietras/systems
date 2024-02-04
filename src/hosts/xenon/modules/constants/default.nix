# Reusable constants are defined here
# All options have default values
# You can use them in other modules
{lib, ...}: {
  options = {
    constants = {
      name = lib.mkOption {
        default = "xenon";
        description = "Name of the machine";
        type = lib.types.str;
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
