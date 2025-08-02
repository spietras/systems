# Virtual machine configuration
{config, ...}: {
  virtualisation = {
    vmVariant = {
      constants = {
        kubernetes = {
          flux = {
            source = {
              # Don't ignore tests
              ignore = "!/tests/";

              # Override the path to cluster resources to use the ones for tests
              path = "tests/clusters/vm/${config.virtualisation.vmVariant.constants.kubernetes.cluster.name}";
            };
          };

          resources = {
            reserved = {
              # Override reserved resources to adjust them for the virtual machine
              system = {
                cpu = "500m";
                memory = "500Mi";
                pid = 100;
                storage = "500Mi";
              };
            };
          };
        };

        # Use a different name for the virtual machine
        name = config.virtualisation.vmVariant.constants.vm.name;

        network = {
          # Use a different host ID for the virtual machine
          hostId = config.virtualisation.vmVariant.constants.vm.network.hostId;

          tailscale = {
            # Use different IP address for the virtual machine
            ip = config.virtualisation.vmVariant.constants.vm.network.tailscale.ip;

            # Don't advertise any routes
            routes = [];
          };
        };
      };

      virtualisation = {
        # CPU cores for the virtual machine
        cores = config.virtualisation.vmVariant.constants.vm.cpu.cores;

        # Path to the disk image
        diskImage = "./bin/${config.virtualisation.vmVariant.constants.vm.name}.qcow2";

        # Size of the disk image
        diskSize = config.virtualisation.vmVariant.constants.vm.disk.size;

        # Memory size for the virtual machine
        memorySize = config.virtualisation.vmVariant.constants.vm.memory.size;

        # Shared directories between the virtual machine and your development machine
        sharedDirectories = {
          # This is needed to transmit your age private keys to the virtual machine
          sops-age-keys = {
            # The private keys should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config/}/sops/age/}";

            # And will be mounted in the virtual machine at this path
            target = builtins.dirOf config.constants.secrets.sops.age.file;
          };
        };
      };
    };
  };
}
