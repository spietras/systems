# Virtual machine configuration
{config, ...}: {
  virtualisation = {
    vmVariant = {
      constants = {
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

        # Use a different name for the virtual machine
        name = config.virtualisation.vmVariant.constants.vm.name;

        network = {
          # Use a different host ID for the virtual machine
          hostId = config.virtualisation.vmVariant.constants.vm.network.hostId;

          tailscale = {
            # Use different IP address for the virtual machine
            ip = config.virtualisation.vmVariant.constants.vm.network.tailscale.ip;
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
          # This is needed to transmit your age private key to the virtual machine
          age-key = {
            # The private key should be stored at this path on your development machine
            source = "\${SOPS_AGE_KEY_DIR:-\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age}";

            # And will be mounted in the virtual machine at this path
            target = "/var/lib/sops/age";
          };
        };
      };
    };
  };
}
