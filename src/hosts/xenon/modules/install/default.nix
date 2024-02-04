# Install script
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    installScript = lib.mkOption {
      # Create shell script with some setup code added automatically
      default = pkgs.writeShellApplication {
        name = "install";

        # pkgs.substituteAll returns a path to a file, so we need to read it
        text = builtins.readFile (
          # This is used to provide data to the script by replacing some strings
          pkgs.substituteAll {
            src = ./install.sh;

            boot = config.constants.storage.partitions.boot.label;
            cat = "${pkgs.coreutils}/bin/cat";
            cp = "${pkgs.coreutils}/bin/cp";
            disk = config.constants.storage.diskPath;
            flake = inputs.self;
            grep = "${pkgs.gnugrep}/bin/grep";
            hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
            home = config.constants.storage.partitions.main.datasets.home.label;
            host = config.constants.name;
            main = config.constants.storage.partitions.main.label;
            mkdir = "${pkgs.coreutils}/bin/mkdir";
            mkfsfat = "${pkgs.dosfstools}/bin/mkfs.fat";
            mkswap = "${pkgs.util-linux}/bin/mkswap";
            mount = "${pkgs.util-linux}/bin/mount";
            mountpoint = "${pkgs.util-linux}/bin/mountpoint";
            nix = config.constants.storage.partitions.main.datasets.nix.label;
            nixosinstall = "${pkgs.nixos-install-tools}/bin/nixos-install";
            parted = "${pkgs.parted}/bin/parted";
            printf = "${pkgs.coreutils}/bin/printf";
            rm = "${pkgs.coreutils}/bin/rm";
            sleep = "${pkgs.coreutils}/bin/sleep";
            softstate = config.constants.storage.partitions.main.datasets.softstate.label;
            swap = config.constants.storage.partitions.swap.label;
            swapoff = "${pkgs.util-linux}/bin/swapoff";
            swapon = "${pkgs.util-linux}/bin/swapon";
            swapsize = (toString config.constants.storage.partitions.swap.size) + "MB";
            udevadm = "${pkgs.eudev}/bin/udevadm";
            umount = "${pkgs.util-linux}/bin/umount";
            zfs = "${pkgs.zfs}/bin/zfs";
            zpool = "${pkgs.zfs}/bin/zpool";
          }
        );
      };
    };
  };
}
