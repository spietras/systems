{pkgs, ...}: {
  home-manager = {
    users = {
      spietras = {
        home = {
          packages = [
            pkgs.beep
          ];
        };

        programs = {
          bat = {
            config = {
              theme = "Visual Studio Dark+";
            };

            enable = true;

            extraPackages = [
              pkgs.bat-extras.batdiff
              pkgs.bat-extras.batgrep
              pkgs.bat-extras.batman
              pkgs.bat-extras.batpipe
              pkgs.bat-extras.batwatch
            ];
          };

          broot = {
            enable = true;
            enableZshIntegration = true;
          };

          btop = {
            enable = true;
          };

          direnv = {
            enable = true;
            enableZshIntegration = true;

            nix-direnv = {
              enable = true;
            };
          };

          exa = {
            enable = true;
            icons = true;
          };

          fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          jq = {
            enable = true;
          };

          man = {
            enable = true;
            generateCaches = true;
          };

          mcfly = {
            enable = true;
            enableZshIntegration = true;
          };

          tealdeer = {
            enable = true;

            settings = {
              updates = {
                auto_update = true;
              };
            };
          };

          yt-dlp = {
            enable = true;
          };
        };

        services = {
          pueue = {
            enable = true;

            settings = {
              shared = {};
              client = {};
              daemon = {};
            };
          };
        };
      };
    };
  };
}
