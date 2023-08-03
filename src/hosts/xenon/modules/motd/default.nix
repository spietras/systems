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

        # Require network to be online
        requires = [
          "network-online.target"
        ];

        script = builtins.readFile (
          pkgs.substituteAll {
            src = ./motd.sh;

            script = pkgs.substituteAll {
              src = ./print.sh;
              isExecutable = true;

              mktemp = "${pkgs.coreutils}/bin/mktemp";
              gum = "${pkgs.gum}/bin/gum";

              script = pkgs.substituteAll {
                src = ./data.sh;
                isExecutable = true;

                shuf = "${pkgs.coreutils}/bin/shuf";
                printf = "${pkgs.coreutils}/bin/printf";
                mktemp = "${pkgs.coreutils}/bin/mktemp";
                curl = "${pkgs.curl}/bin/curl";
                jq = "${pkgs.jq}/bin/jq";
                tr = "${pkgs.coreutils}/bin/tr";
                sed = "${pkgs.gnused}/bin/sed";
                awk = "${pkgs.gawk}/bin/awk";
                krabby = "${pkgs.krabby}/bin/krabby";
                base64 = "${pkgs.coreutils}/bin/base64";
                rm = "${pkgs.coreutils}/bin/rm";
              };

              printf = "${pkgs.coreutils}/bin/printf";
              jq = "${pkgs.jq}/bin/jq";
              base64 = "${pkgs.coreutils}/bin/base64";
              tr = "${pkgs.coreutils}/bin/tr";
              xargs = "${pkgs.findutils}/bin/xargs";
              rm = "${pkgs.coreutils}/bin/rm";
            };

            motdfile = config.users.motdFile;
            mktemp = "${pkgs.coreutils}/bin/mktemp";
            cat = "${pkgs.coreutils}/bin/cat";
            rm = "${pkgs.coreutils}/bin/rm";
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
