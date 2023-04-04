{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    vmVariantWithBootLoader = {
      boot = {
        initrd = {
          postDeviceCommands = builtins.readFile (pkgs.substituteAll {
            src = ../scripts/vm.sh;

            disk = config.constants.vm.diskPath;
            main = config.constants.storage.partitions.main.label;
            swap = config.constants.storage.partitions.swap.label;
            nix = config.constants.storage.partitions.main.datasets.nix.label;
            home = config.constants.storage.partitions.main.datasets.home.label;
            hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
            softstate = config.constants.storage.partitions.main.datasets.softstate.label;
            swapsize = (builtins.toString config.constants.vm.swapSize) + "MB";

            parted = "${pkgs.parted}/bin/parted";
            udevadm = "udevadm";
            zpool = "zpool";
            zfs = "zfs";
            mkswap = "mkswap";
          });
        };
      };

      virtualisation = {
        useEFIBoot = true;
        useDefaultFilesystems = false;
        writableStoreUseTmpfs = false;
        diskImage = "./bin/${config.system.name}.qcow2";
        efiVars = "./bin/${config.system.name}-efi-vars.fd";

        fileSystems = {
          "/" = {
            device = "none";
            fsType = "tmpfs";
            options = ["mode=0755"];
          };

          "/nix" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.nix.label}";
            fsType = "zfs";
            options = ["zfsutil"];
            neededForBoot = true;
          };

          "/home" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.home.label}";
            fsType = "zfs";
            options = ["zfsutil"];
            neededForBoot = true;
          };

          "/${config.constants.storage.partitions.main.datasets.hardstate.label}" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.hardstate.label}";
            fsType = "zfs";
            options = ["zfsutil"];
            neededForBoot = true;
          };

          "/${config.constants.storage.partitions.main.datasets.softstate.label}" = {
            device = "${config.constants.storage.partitions.main.label}/${config.constants.storage.partitions.main.datasets.softstate.label}";
            fsType = "zfs";
            options = ["zfsutil"];
            neededForBoot = true;
          };
        };

        sharedDirectories = {
          ageKey = {
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";
            target = "/${config.constants.storage.partitions.main.datasets.hardstate.label}/sops/age";
          };
        };

        cores = config.constants.vm.cores;
        diskSize = config.constants.vm.diskSize;
        memorySize = config.constants.vm.memorySize;
      };
    };
  };
}
