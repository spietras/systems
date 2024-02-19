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

                  disk = config.virtualisation.vmVariant.constants.disk.path;
                  hardstate = config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.hardstate.label;
                  home = config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.home.label;
                  main = config.virtualisation.vmVariant.constants.disk.partitions.main.label;
                  nix = config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.nix.label;
                  parted = "${pkgs.parted}/bin/parted";
                  softstate = config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.softstate.label;
                  swap = config.virtualisation.vmVariant.constants.disk.partitions.swap.label;
                  swapSize = (toString config.virtualisation.vmVariant.constants.disk.partitions.swap.size) + "MB";
                  zfsPackage = config.boot.zfs.package;
                }
              )
            )
            + config.boot.initrd.postDeviceCommands
          );
        };
      };

      constants = {
        disk = {
          # Override the disk path to use the virtual machine disk
          path = config.constants.vm.disk.path;

          partitions = {
            main = {
              volumes = {
                longhorn = {
                  # Override the longhorn volume size to use the virtual machine disk size
                  size = config.constants.vm.disk.partitions.main.volumes.longhorn.size;
                };
              };
            };

            swap = {
              # Override the swap partition size to use the virtual machine swap size
              size = config.constants.vm.disk.partitions.swap.size;
            };
          };
        };

        kubernetes = {
          flux = {
            source = {
              # Override the path to cluster resources to use the ones for tests
              path = "tests/clusters/vm/${config.virtualisation.vmVariant.constants.kubernetes.cluster.name}";

              # Don't ignore tests
              ignore = "!/tests/";
            };
          };

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

        # Use different name for the virtual machine
        name = "xenon-vm";

        network = {
          # Use different host ID for the virtual machine
          hostId = "3a299589";

          tailscale = {
            # Use different IP address for the virtual machine
            ip = "100.127.132.11";
          };
        };
      };

      virtualisation = {
        cores = config.virtualisation.vmVariant.constants.vm.cpu.cores;

        # This file will be created on your development machine
        diskImage = "./bin/${config.virtualisation.vmVariant.system.name}.qcow2";

        diskSize = config.virtualisation.vmVariant.constants.vm.disk.size;

        # Filesystems need to be defined separately for virtual machines
        # But it's the same as in the real system
        # With the exception of boot partition
        fileSystems = {
          "/" = config.fileSystems."/";

          "/home" =
            config.fileSystems."/home"
            // {
              device = "${config.virtualisation.vmVariant.constants.disk.partitions.main.label}/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.home.label}";
            };

          "/nix" =
            config.fileSystems."/nix"
            // {
              device = "${config.virtualisation.vmVariant.constants.disk.partitions.main.label}/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.nix.label}";
            };

          "/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.hardstate.label}" =
            config.fileSystems."/${config.constants.disk.partitions.main.datasets.hardstate.label}"
            // {
              device = "${config.virtualisation.vmVariant.constants.disk.partitions.main.label}/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.hardstate.label}";
            };

          "/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.softstate.label}" =
            config.fileSystems."/${config.constants.disk.partitions.main.datasets.softstate.label}"
            // {
              device = "${config.virtualisation.vmVariant.constants.disk.partitions.main.label}/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.softstate.label}";
            };

          "/var/lib/longhorn" =
            config.fileSystems."/var/lib/longhorn"
            // {
              device = "/dev/disk/by-label/${config.virtualisation.vmVariant.constants.disk.partitions.main.volumes.longhorn.label}";
            };
        };

        memorySize = config.virtualisation.vmVariant.constants.vm.memory.size;

        # Shared directories between the virtual machine and your development machine
        sharedDirectories = {
          # This is needed to transmit your age private key to the virtual machine
          age-key = {
            # The private key should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";

            # And will be mounted in the virtual machine at this path
            target = "/${config.virtualisation.vmVariant.constants.disk.partitions.main.datasets.hardstate.label}/sops/age";
          };
        };

        # Use our custom filesystems instead of the default ones
        useDefaultFilesystems = false;
      };
    };
  };
}
