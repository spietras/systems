# Message of the Day
{
  config,
  pkgs,
  ...
}: let
  dataScript = pkgs.writeShellApplication {
    # Name of the script
    name = "data";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils pkgs.curl pkgs.gawk pkgs.gnused pkgs.jq pkgs.krabby];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./data.sh;
      }
    );
  };
  printScript = pkgs.writeShellApplication {
    # Name of the script
    name = "print";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils pkgs.gum pkgs.jq];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./print.sh;

        script = "${dataScript}/bin/data";
      }
    );
  };
  motdScript = pkgs.writeShellApplication {
    # Name of the script
    name = "motd";

    # Packages available in the script
    runtimeInputs = [pkgs.coreutils];

    # Load the script with substituted values
    text = builtins.readFile (
      # Substitute values in the script
      pkgs.substituteAll {
        # Use this file as source
        src = ./motd.sh;

        # Provide values to substitute
        motdfile = config.users.motdFile;
        script = "${printScript}/bin/print";
      }
    );
  };
in {
  systemd = {
    services = {
      # Create a service for changing the MOTD
      motd = {
        description = "Change the MOTD";

        requires = [
          # Require network to be online
          "network-online.target"
        ];

        script = "${motdScript}/bin/motd";

        serviceConfig = {
          # This is needed to format the output correctly
          StandardOutput = "tty";

          # Restart on failure
          Restart = "on-failure";
        };

        # Run every day at midnight
        startAt = "00:00";

        unitConfig = {
          # Limit the number of restarts
          StartLimitIntervalSec = 60;
          StartLimitBurst = 10;
        };
      };
    };
  };

  users = {
    # Store MOTD in this file
    motdFile = "/etc/motd";
  };
}
