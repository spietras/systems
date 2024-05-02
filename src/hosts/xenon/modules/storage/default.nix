# Storage configuration
{inputs, ...}: {
  imports = [
    # Import Disko modules
    inputs.disko.nixosModules.disko
  ];

  disko = {
    devices = {
      disk = {
        main = {
          content = {
            # Use GPT partition table
            type = "gpt";

            partitions = {
              boot = {
                # Size of the boot partition
                size = "512M";

                # EFI system partition
                type = "EF00";

                content = {
                  # This partition contains a filesystem
                  type = "filesystem";

                  # Format the partition as FAT
                  format = "vfat";

                  # Mount the partition at /boot
                  mountpoint = "/boot";
                };
              };

              main = {
                # Use the rest of the disk for the main partition
                size = "100%";

                content = {
                  # This partition contains a filesystem
                  type = "filesystem";

                  # Format the partition as ext4
                  format = "ext4";

                  # Mount the partition at /
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems = {
    "/boot" = {
      # Obviously
      neededForBoot = true;
    };

    "/" = {
      # Contains data needed for booting
      neededForBoot = true;
    };
  };

  services = {
    fstrim = {
      # Enable automatic periodic TRIM
      enable = true;

      # TRIM once a week on Sunday at 3 AM
      interval = "Sun, 03:00";
    };

    smartd = {
      # Enable smartmontools daemon
      enable = true;

      extraOptions = [
        # This prevents smartd from failing if no SMART capable devices are found (like in a VM)
        "-q never"
      ];
    };
  };
}
