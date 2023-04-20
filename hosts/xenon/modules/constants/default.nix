# Reusable constants are defined here
# You can use them in other modules
# The way to define this is a little bit weird, but it works
{lib, ...}: {
  options = {
    constants = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "xenon";

        network = {
          # This is just randomly generated, but is needed
          hostId = "9f86d081";
        };

        storage = {
          # Xenon has one SSD
          diskPath = "/dev/sda";

          partitions = {
            boot = {
              label = "boot";
            };

            main = {
              label = "main";
              datasets = {
                nix = {
                  label = "nix";
                };

                home = {
                  label = "home";
                };

                hardstate = {
                  label = "hardstate";
                };

                softstate = {
                  label = "softstate";
                };
              };
            };

            swap = {
              label = "swap";

              # 16GB for swap
              size = 16384;
            };
          };
        };

        platform = "x86_64-linux";

        vm = {
          # You need these resources to your development machine to run the VM
          # You can change these to whatever you want, but the defaults should be fine
          cores = 4;
          diskSize = 8192;
          memorySize = 4096;
          swapSize = 1024;

          # In the virtual machine, the disk is called vda
          diskPath = "/dev/vda";
        };
      };

      description = "Constants";
    };
  };
}
