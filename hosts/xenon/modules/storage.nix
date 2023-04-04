{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["mode=0755"];
    };

    "/boot" = {
      device = "/dev/disk/by-label/${config.constants.storage.partitions.boot.label}";
      fsType = "vfat";
      neededForBoot = true;
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

  swapDevices = [
    {
      device = "/dev/disk/by-label/${config.constants.storage.partitions.swap.label}";
    }
  ];

  systemd = {
    services = {
      zfs-mount = {
        enable = false;
      };
    };
  };

  environment = {
    persistence = {
      "/hardstate" = {
        hideMounts = true;
      };
      "/softstate" = {
        hideMounts = true;

        directories = [
          "/var/lib/systemd/coredump"
        ];

        files = [
          "/etc/machine-id"
        ];
      };
    };
  };
}
