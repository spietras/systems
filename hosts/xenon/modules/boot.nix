{config, ...}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
    };

    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];

      kernelModules = [];
    };

    zfs = {
      devNodes = "/dev/disk/by-path";
    };

    kernelModules = ["kvm-intel"];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = [];
    supportedFilesystems = ["zfs"];
  };
}
