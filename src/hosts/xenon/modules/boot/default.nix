# Boot configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    # Disable console messages
    consoleLogLevel = 0;

    # Kernel modules configuration
    extraModprobeConfig = ''
      # OverlayFS options
      # Enable index to pevent breaking hardlinks
      # Enable metacopy to speed up recursive metadata updates
      # Enable redirect_dir to allow renaming directories on lower layers
      # Enable xino_auto to let OverlayFS decide whether to use alternative inode indexing
      options overlay index=on metacopy=on redirect_dir=on xino_auto=on
    '';

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

          hardstate = config.constants.disk.partitions.main.datasets.hardstate.label;

          hardstateDirectories = (
            lib.strings.concatStringsSep
            ":"
            (
              map
              (directory: directory.directory)
              config.environment.persistence."/hardstate".directories
            )
          );

          main = config.constants.disk.partitions.main.label;
          softstate = config.constants.disk.partitions.main.datasets.softstate.label;

          softstateDirectories = (
            lib.strings.concatStringsSep
            ":"
            (
              map
              (directory: directory.directory)
              config.environment.persistence."/softstate".directories
            )
          );
        }
      );

      supportedFilesystems = [
        # Needed to support ZFS at boot
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

        # Increase socket buffer size
        "net.core.rmem_max" = 2500000;
        "net.core.wmem_max" = 2500000;
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
      systemd-boot = {
        # Keep maximum 5 previous generations
        configurationLimit = 5;

        # Try to autodetect the best resolution
        consoleMode = "auto";

        # Disable editing kernel parameters
        editor = false;

        # Use systemd-boot as bootloader
        enable = true;

        memtest86 = {
          # Enable memtest86 to be able to test RAM
          enable = true;

          # This is needed for correct ordering of boot entries
          entryFilename = "a_memtest86.conf";
        };

        netbootxyz = {
          # Enable netboot.xyz to be able to boot any OS from network
          enable = true;

          # This is needed for correct ordering of boot entries
          entryFilename = "a_netbootxyz.conf";
        };
      };
    };

    plymouth = {
      # Enable splash screen
      enable = true;

      theme = "angular";

      themePackages = [
        # See https://github.com/adi1090x/plymouth-themes for more themes
        (pkgs.adi1090x-plymouth-themes.override {selected_themes = ["angular"];})
      ];
    };

    supportedFilesystems = [
      # Also needed to support ZFS at boot
      "zfs"
    ];
  };

  systemd = {
    services = {
      # Splash screen showoff
      splash-delay = {
        before = [
          # Make plymouth wait for this service
          "plymouth-quit.service"
        ];

        description = "Wait at boot to show splash screen animation";

        serviceConfig = {
          # Run only once at startup
          Type = "oneshot";
        };

        # Adjust the delay to your liking
        script = "sleep 1";

        wantedBy = [
          # Run at startup
          "multi-user.target"
        ];
      };
    };
  };
}
