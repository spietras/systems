# Virtual machine configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  virtualisation = {
    vmVariant = {
      boot = {
        initrd = {
          postDeviceCommands = lib.mkForce (
            (
              # pkgs.substituteAll returns a path to a file, so we need to read it
              builtins.readFile (
                # This is used to provide data to the script by replacing some strings
                pkgs.substituteAll {
                  src = ./prepare.sh;

                  disk = config.virtualisation.vmVariant.constants.storage.diskPath;
                  hardstate = config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.hardstate.label;
                  home = config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.home.label;
                  main = config.virtualisation.vmVariant.constants.storage.partitions.main.label;
                  mkswap = "${pkgs.util-linux}/bin/mkswap";
                  nix = config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.nix.label;
                  parted = "${pkgs.parted}/bin/parted";
                  printf = "${pkgs.coreutils}/bin/printf";
                  sleep = "${pkgs.coreutils}/bin/sleep";
                  softstate = config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.softstate.label;
                  swap = config.virtualisation.vmVariant.constants.storage.partitions.swap.label;
                  swapSize = (toString config.virtualisation.vmVariant.constants.storage.partitions.swap.size) + "MB";
                  udevadm = "${pkgs.eudev}/bin/udevadm";
                  zfs = "${pkgs.zfs}/bin/zfs";
                  zpool = "${pkgs.zfs}/bin/zpool";
                }
              )
            )
            + config.boot.initrd.postDeviceCommands
          );
        };
      };

      constants = {
        kubernetes = {
          resources = {
            reserved = {
              # Override reserved resources to adjust them for the virtual machine
              system = {
                cpu = "500m";
                memory = "500Mi";
                storage = "500Mi";
                pid = 100;
              };
            };
          };
        };

        storage = {
          # Override the disk path to use the virtual machine disk
          diskPath = config.constants.vm.diskPath;

          partitions = {
            swap = {
              # Override the swap partition size to use the virtual machine swap size
              size = config.constants.vm.swapSize;
            };
          };
        };
      };

      virtualisation = {
        cores = config.virtualisation.vmVariant.constants.vm.cores;

        # This file will be created on your development machine
        diskImage = "./bin/${config.virtualisation.vmVariant.system.name}.qcow2";

        diskSize = config.virtualisation.vmVariant.constants.vm.diskSize;

        # Filesystems need to be defined separately for virtual machines
        # But it's the same as in the real system
        # With the exception of boot partition
        fileSystems = {
          "/" = config.fileSystems."/";

          "/home" =
            config.fileSystems."/home"
            // {
              device = "${config.virtualisation.vmVariant.constants.storage.partitions.main.label}/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.home.label}";
            };

          "/nix" =
            config.fileSystems."/nix"
            // {
              device = "${config.virtualisation.vmVariant.constants.storage.partitions.main.label}/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.nix.label}";
            };

          "/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.hardstate.label}" =
            config.fileSystems."/${config.constants.storage.partitions.main.datasets.hardstate.label}"
            // {
              device = "${config.virtualisation.vmVariant.constants.storage.partitions.main.label}/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.hardstate.label}";
            };

          "/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.softstate.label}" =
            config.fileSystems."/${config.constants.storage.partitions.main.datasets.softstate.label}"
            // {
              device = "${config.virtualisation.vmVariant.constants.storage.partitions.main.label}/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.softstate.label}";
            };
        };

        memorySize = config.virtualisation.vmVariant.constants.vm.memorySize;

        # Shared directories between the virtual machine and your development machine
        sharedDirectories = {
          # This is needed to transmit your age private key to the virtual machine
          age-key = {
            # The private key should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";

            # And will be mounted in the virtual machine at this path
            target = "/${config.virtualisation.vmVariant.constants.storage.partitions.main.datasets.hardstate.label}/sops/age";
          };
        };

        # Use our custom filesystems instead of the default ones
        useDefaultFilesystems = false;
      };
    };
  };
}
