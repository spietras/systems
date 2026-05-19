# Virtual machine configuration
{config, ...}: {
  virtualisation = {
    vmVariant = {
      constants = {
        kubernetes = {
          cluster = {
            # Use different cluster in the virtual machine
            name = config.virtualisation.vmVariant.constants.vm.kubernetes.cluster.name;
          };

          network = {
            addresses = {
              # Use different cluster and service CIDR in the virtual machine
              cluster = config.virtualisation.vmVariant.constants.vm.kubernetes.network.addresses.cluster;
              service = config.virtualisation.vmVariant.constants.vm.kubernetes.network.addresses.service;
            };
          };

          resources = {
            reserved = {
              # Override reserved resources to adjust them for the virtual machine
              system = {
                cpu = config.virtualisation.vmVariant.constants.vm.kubernetes.resources.reserved.system.cpu;
                memory = config.virtualisation.vmVariant.constants.vm.kubernetes.resources.reserved.system.memory;
                pid = config.virtualisation.vmVariant.constants.vm.kubernetes.resources.reserved.system.pid;
                storage = config.virtualisation.vmVariant.constants.vm.kubernetes.resources.reserved.system.storage;
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

            # Advertise different routes for the virtual machine
            routes = config.virtualisation.vmVariant.constants.vm.network.tailscale.routes;
          };
        };
      };

      virtualisation = {
        # CPU cores for the virtual machine
        cores = config.virtualisation.vmVariant.constants.vm.resources.cpu.cores;

        # Path to the disk image
        diskImage = "./bin/${config.virtualisation.vmVariant.constants.vm.name}.qcow2";

        # Size of the disk image
        diskSize = config.virtualisation.vmVariant.constants.vm.resources.disk.size;

        # Memory size for the virtual machine
        memorySize = config.virtualisation.vmVariant.constants.vm.resources.memory.size;

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
