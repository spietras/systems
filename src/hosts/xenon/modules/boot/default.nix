# Boot configuration
{
  config,
  pkgs,
  ...
}: {
  boot = {
    # Disable console messages
    consoleLogLevel = 0;

    initrd = {
      # This was autodetected by nixos-generate-config
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];

      # Setup directories for persistent storage at boot
      postDeviceCommands = builtins.readFile (
        pkgs.substituteAll {
          src = ./prepare.sh;

          main = config.constants.storage.partitions.main.label;
          hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
          softstate = config.constants.storage.partitions.main.datasets.softstate.label;

          udevadm = "udevadm";
        }
      );

      # Needed to support ZFS at boot
      supportedFilesystems = [
        "zfs"
      ];

      # Disable log messages
      verbose = false;
    };

    kernel = {
      sysctl = {
        # Enable SysRq
        # But only for logging level, keyboard, sync, remount, signals and reboot
        "kernel.sysrq" = 244;

        # Ignore incoming ICMP redirects to prevent MITM attacks
        "net.ipv4.conf.all.accept_redirects" = false;
        "net.ipv4.conf.all.secure_redirects" = false;
        "net.ipv4.conf.default.accept_redirects" = false;
        "net.ipv4.conf.default.secure_redirects" = false;
        "net.ipv6.conf.all.accept_redirects" = false;
        "net.ipv6.conf.default.accept_redirects" = false;

        # Ignore outgoing ICMP redirects to prevent MITM attacks
        "net.ipv4.conf.all.send_redirects" = false;
        "net.ipv4.conf.default.send_redirects" = false;
      };
    };

    # This was autodetected by nixos-generate-config
    kernelModules = [
      "kvm-intel"
    ];

    # This is needed for ZFS to work
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

    kernelParams = [
      # Reboot after 10 seconds on panic
      "kernel.panic=10"

      # Panic on failure
      "boot.panic_on_fail"

      # Disable log messages
      "quiet"
      "udev.log_level=3"

      # Enable splash screen
      "splash"
    ];

    loader = {
      # Use systemd-boot as bootloader
      systemd-boot = {
        # Keep maximum 5 previous generations
        configurationLimit = 5;

        # Try to autodetect the best resolution
        consoleMode = "auto";

        # Disable editing kernel parameters
        editor = false;

        enable = true;

        # Enable memtest86 to be able to test RAM
        memtest86 = {
          enable = true;

          # This is needed for correct ordering of boot entries
          entryFilename = "a_memtest86.conf";
        };

        # Enable netboot.xyz to be able to boot any OS from network
        netbootxyz = {
          enable = true;

          # This is needed for correct ordering of boot entries
          entryFilename = "a_netbootxyz.conf";
        };
      };
    };

    # Enable splash screen
    plymouth = {
      enable = true;
      theme = "angular";

      themePackages = [
        # See https://github.com/adi1090x/plymouth-themes for more themes
        (pkgs.adi1090x-plymouth-themes.override {selected_themes = ["angular"];})
      ];
    };

    # Also needed to support ZFS at boot
    supportedFilesystems = [
      "zfs"
    ];
  };

  systemd = {
    services = {
      # Splash screen showoff
      splash-delay = {
        # Make plymouth wait for this service
        before = [
          "plymouth-quit.service"
        ];

        description = "Wait at boot to show splash screen animation";

        serviceConfig = {
          # Run only once at startup
          Type = "oneshot";
        };

        # Adjust the delay to your liking
        script = "sleep 1";

        # Run at startup
        wantedBy = [
          "multi-user.target"
        ];
      };
    };
  };
}
