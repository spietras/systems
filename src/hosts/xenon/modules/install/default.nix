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

            boot = config.constants.disk.partitions.boot.label;
            disk = config.constants.disk.path;
            flake = inputs.self;
            grep = "${pkgs.gnugrep}/bin/grep";
            hardstate = config.constants.disk.partitions.main.datasets.hardstate.label;
            home = config.constants.disk.partitions.main.datasets.home.label;
            host = config.constants.name;
            main = config.constants.disk.partitions.main.label;
            mkfsfat = "${pkgs.dosfstools}/bin/mkfs.fat";
            nix = config.constants.disk.partitions.main.datasets.nix.label;
            nixosinstall = "${pkgs.nixos-install-tools}/bin/nixos-install";
            parted = "${pkgs.parted}/bin/parted";
            softstate = config.constants.disk.partitions.main.datasets.softstate.label;
            swap = config.constants.disk.partitions.swap.label;
            swapSize = (toString config.constants.disk.partitions.swap.size) + "MB";
            zfsPackage = config.boot.zfs.package;
          }
        );
      };
    };
  };
}
