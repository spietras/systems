# Storage configuration
{
  inputs,
  config,
  ...
}: {
  imports = [
    # Import impermanence module
    inputs.impermanence.nixosModules.impermanence
  ];

  environment = {
    persistence = {
      # State that should be preserved and backed up
      "/hardstate" = {
        # Don't display as mounts to reduce clutter
        hideMounts = true;
      };

      # State that should be preserved but it's okay to lose
      "/softstate" = {
        directories = [
          # Cache that should be preserved
          "/var/cache/"

          # Games data
          "/var/games/"

          # Various local state
          "/var/lib/"

          # Logs
          "/var/log/"

          # Temporary files that should be preserved
          "/var/tmp/"
        ];

        files = [
          # Machine ID should be preserved and not changed
          "/etc/machine-id"
        ];

        # Don't display as mounts to reduce clutter
        hideMounts = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      # tmpfs uses RAM
      device = "none";

      # use tmpfs for root
      fsType = "tmpfs";

      options = [
        # Set correct permissions
        "mode=0755"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/${config.constants.disk.partitions.boot.label}";

      # /boot uses FAT32, but mount only recognizes vfat type
      fsType = "vfat";

      # Obviously
      neededForBoot = true;
    };

    "/home" = {
      device = "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.home.label}";

      # /home is a ZFS dataset
      fsType = "zfs";

      # /home is needed at boot, so nix can create the user environment
      neededForBoot = true;

      options = [
        # Use ZFS for mounting logic
        "zfsutil"
      ];
    };

    "/nix" = {
      device = "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.nix.label}";

      # /nix is a ZFS dataset
      fsType = "zfs";

      # Nix data is needed for boot, because everything important is symlinked from there
      neededForBoot = true;

      options = [
        # Use ZFS for mounting logic
        "zfsutil"
      ];
    };

    "/${config.constants.disk.partitions.main.datasets.hardstate.label}" = {
      device = "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.hardstate.label}";

      # hardstate is a ZFS dataset
      fsType = "zfs";

      # mark it as needed for boot, so if there are any important files in it, they are available
      neededForBoot = true;

      options = [
        # Use ZFS for mounting logic
        "zfsutil"
      ];
    };

    "/${config.constants.disk.partitions.main.datasets.softstate.label}" = {
      device = "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.softstate.label}";

      # softstate is a ZFS dataset
      fsType = "zfs";

      # mark it as needed for boot, so if there are any important files in it, they are available
      neededForBoot = true;

      options = [
        # Use ZFS for mounting logic
        "zfsutil"
      ];
    };
  };

  services = {
    sanoid = {
      datasets = {
        "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.home.label}" = {
          # Keep 30 past snapshots that are taken once a day
          daily = 30;

          # Keep 24 past snapshots that are taken once an hour
          hourly = 24;

          # Don't keep any monthly snapshots
          monthly = 0;
        };

        "${config.constants.disk.partitions.main.label}/${config.constants.disk.partitions.main.datasets.hardstate.label}" = {
          # Keep 30 past snapshots that are taken once a day
          daily = 30;

          # Keep 24 past snapshots that are taken once an hour
          hourly = 24;

          # Don't keep any monthly snapshots
          monthly = 0;
        };
      };

      # Enable periodic snapshots of the ZFS datasets
      enable = true;
    };

    smartd = {
      # Enable smartmontools daemon
      enable = true;

      extraOptions = [
        # This prevents smartd from failing if no SMART capable devices are found (like in a VM)
        "-q never"
      ];
    };

    zfs = {
      autoScrub = {
        # Enable automatic periodic scrubbing
        enable = true;

        # Scrub once a week on Sunday at 3 AM
        interval = "Sun, 03:00";
      };

      trim = {
        # Enable automatic periodic TRIM
        enable = true;

        # TRIM once a week on Sunday at 3 AM
        interval = "Sun, 03:00";
      };
    };
  };

  swapDevices = [
    # One swap device on separate partition
    {
      # We need to use partlabel here, because regular label can change with encryption
      device = "/dev/disk/by-partlabel/${config.constants.disk.partitions.swap.label}";

      randomEncryption = {
        # Allow TRIM requests to be sent to the swap device
        allowDiscards = true;

        # Enable encryption of swap
        enable = true;
      };
    }
  ];

  systemd = {
    services = {
      zfs-mount = {
        # Disable ZFS mount service, because we mount ZFS datasets manually
        enable = false;
      };
    };
  };
}
