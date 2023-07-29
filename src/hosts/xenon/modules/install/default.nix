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

            flake = inputs.self;
            host = config.constants.name;
            disk = config.constants.storage.diskPath;
            boot = config.constants.storage.partitions.boot.label;
            main = config.constants.storage.partitions.main.label;
            swap = config.constants.storage.partitions.swap.label;
            nix = config.constants.storage.partitions.main.datasets.nix.label;
            home = config.constants.storage.partitions.main.datasets.home.label;
            hardstate = config.constants.storage.partitions.main.datasets.hardstate.label;
            softstate = config.constants.storage.partitions.main.datasets.softstate.label;
            swapsize = (builtins.toString config.constants.storage.partitions.swap.size) + "MB";
          }
        );
      };
    };
  };
}
