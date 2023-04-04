{lib, ...}: {
  options = {
    constants = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "xenon";

        network = {
          hostId = "9f86d081";
        };

        storage = {
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
              size = 1024;
            };
          };
        };

        platform = "x86_64-linux";

        vm = {
          cores = 4;
          diskSize = 8192;
          memorySize = 4096;
          swapSize = 1024;
          diskPath = "/dev/vda";
        };
      };

      description = "Constants";
    };
  };
}
