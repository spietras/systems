# Virtual machine configuration
{
  config,
  pkgs,
  ...
}: {
  virtualisation = {
    vmVariantWithBootLoader = {
      boot = {
        initrd = {
          # pkgs.substituteAll returns a path to a file, so we need to read it
          postDeviceCommands = builtins.readFile (
            # This is used to provide data to the script by replacing some strings
            pkgs.substituteAll {
              src = ./prepare.sh;

              disk = config.constants.vm.diskPath;
              main = config.constants.storage.partitions.main.label;
              swap = config.constants.storage.partitions.swap.label;
              nix = config.constants.storage.partitions.main.datasets.nix.label;
              home = config.constants.storage.partitions.main.datasets.home.label;
              hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
              softstate = config.constants.storage.partitions.main.datasets.softstate.label;
              swapsize = (builtins.toString config.constants.vm.swapSize) + "MB";

              # parted is not in PATH so we need to provide the full path
              parted = "${pkgs.parted}/bin/parted";

              # All utilities below are already in PATH
              udevadm = "udevadm";
              zpool = "zpool";
              zfs = "zfs";
              mkswap = "mkswap";
            }
          );
        };
      };

      virtualisation = {
        cores = config.constants.vm.cores;

        # This file will be created on your development machine
        diskImage = "./bin/${config.system.name}.qcow2";

        diskSize = config.constants.vm.diskSize;

        # This file will also be created on your development machine
        efiVars = "./bin/${config.system.name}-efi-vars.fd";

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
          ageKey = {
            # The private key should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";

            # And will be mounted in the virtual machine at this path
            target = "/${config.constants.storage.partitions.main.datasets.hardstate.label}/sops/age";
          };
        };

        # Use our custom filesystems instead of the default ones
        useDefaultFilesystems = false;

        # Use UEFI instead of BIOS
        useEFIBoot = true;
      };
    };
  };
}
