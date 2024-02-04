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

                  disk = config.constants.vm.diskPath;
                  hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
                  home = config.constants.storage.partitions.main.datasets.home.label;
                  main = config.constants.storage.partitions.main.label;
                  mkswap = "${pkgs.util-linux}/bin/mkswap";
                  nix = config.constants.storage.partitions.main.datasets.nix.label;
                  parted = "${pkgs.parted}/bin/parted";
                  printf = "${pkgs.coreutils}/bin/printf";
                  sleep = "${pkgs.coreutils}/bin/sleep";
                  softstate = config.constants.storage.partitions.main.datasets.softstate.label;
                  swap = config.constants.storage.partitions.swap.label;
                  swapSize = (toString config.constants.vm.swapSize) + "MB";
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

      virtualisation = {
        cores = config.constants.vm.cores;

        # This file will be created on your development machine
        diskImage = "./bin/${config.system.name}.qcow2";

        diskSize = config.constants.vm.diskSize;

        # Filesystems need to be defined separately for virtual machines
        # But it's the same as in the real system
        # With the exception of boot partition
        fileSystems = {
          "/" = {
            device = "none";
            fsType = "tmpfs";

            options = [
              "mode=0755"
            ];
          };

          "/nix" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.nix.label}";
            fsType = "zfs";
            neededForBoot = true;

            options = [
              "zfsutil"
            ];
          };

          "/home" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.home.label}";
            fsType = "zfs";
            neededForBoot = true;

            options = [
              "zfsutil"
            ];
          };

          "/${config.constants.storage.partitions.main.datasets.hardstate.label}" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.hardstate.label}";
            fsType = "zfs";
            neededForBoot = true;

            options = [
              "zfsutil"
            ];
          };

          "/${config.constants.storage.partitions.main.datasets.softstate.label}" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.softstate.label}";
            fsType = "zfs";
            neededForBoot = true;

            options = [
              "zfsutil"
            ];
          };
        };

        memorySize = config.constants.vm.memorySize;

        # Shared directories between the virtual machine and your development machine
        sharedDirectories = {
          # This is needed to transmit your age private key to the virtual machine
          age-key = {
            # The private key should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";

            # And will be mounted in the virtual machine at this path
            target = "/${config.constants.storage.partitions.main.datasets.hardstate.label}/sops/age";
          };
        };

        # Use our custom filesystems instead of the default ones
        useDefaultFilesystems = false;
      };
    };
  };
}
