# Message of the Day
{
  config,
  pkgs,
  ...
}: {
  systemd = {
    services = {
      # Create a service for changing the MOTD
      motd = {
        description = "Change the MOTD";

        requires = [
          # Require network to be online
          "network-online.target"
        ];

        script = builtins.readFile (
          pkgs.substituteAll {
            src = ./motd.sh;

            cat = "${pkgs.coreutils}/bin/cat";
            mktemp = "${pkgs.coreutils}/bin/mktemp";
            motdfile = config.users.motdFile;
            rm = "${pkgs.coreutils}/bin/rm";

            script = pkgs.substituteAll {
              src = ./print.sh;
              isExecutable = true;

              base64 = "${pkgs.coreutils}/bin/base64";
              gum = "${pkgs.gum}/bin/gum";
              jq = "${pkgs.jq}/bin/jq";
              mktemp = "${pkgs.coreutils}/bin/mktemp";
              printf = "${pkgs.coreutils}/bin/printf";
              rm = "${pkgs.coreutils}/bin/rm";

              script = pkgs.substituteAll {
                src = ./data.sh;
                isExecutable = true;

                awk = "${pkgs.gawk}/bin/awk";
                base64 = "${pkgs.coreutils}/bin/base64";
                curl = "${pkgs.curl}/bin/curl";
                jq = "${pkgs.jq}/bin/jq";
                krabby = "${pkgs.krabby}/bin/krabby";
                mktemp = "${pkgs.coreutils}/bin/mktemp";
                printf = "${pkgs.coreutils}/bin/printf";
                rm = "${pkgs.coreutils}/bin/rm";
                sed = "${pkgs.gnused}/bin/sed";
                shuf = "${pkgs.coreutils}/bin/shuf";
                tr = "${pkgs.coreutils}/bin/tr";
              };

              tr = "${pkgs.coreutils}/bin/tr";
              xargs = "${pkgs.findutils}/bin/xargs";
            };
          }
        );

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
    motdFile = "/etc/motd";
  };
}
