{
  config,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      spietras = {
        fonts = {
          fontconfig = {
            enable = true;
          };
        };

        home = {
          language = {
            base = "en_US.UTF-8";

            address = "pl_PL.UTF-8";
            collate = "pl_PL.UTF-8";
            ctype = "pl_PL.UTF-8";
            measurement = "pl_PL.UTF-8";
            monetary = "pl_PL.UTF-8";
            name = "pl_PL.UTF-8";
            numeric = "pl_PL.UTF-8";
            paper = "pl_PL.UTF-8";
            telephone = "pl_PL.UTF-8";
            time = "pl_PL.UTF-8";
          };

          packages = [
            pkgs.beep
          ];

          stateVersion = "22.11";
        };

        manual = {
          manpages = {
            enable = false;
          };
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

          git = {
            enable = true;

            difftastic = {
              enable = true;
            };

            userEmail = "me@spietras.dev";
            userName = "spietras";
          };

          jq = {
            enable = true;
          };

          keychain = {
            enable = true;
            enableZshIntegration = true;

            keys = [
            ];
          };

          lazygit = {
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

          starship = {
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

          zsh = {
            enable = true;
            enableAutosuggestions = true;
            enableCompletion = true;
            enableVteIntegration = true;

            history = {
              ignoreDups = true;
            };

            historySubstringSearch = {
              enable = true;

              searchDownKey = [
                "^[[B"
                "\\eOB"
                "^[OB"
              ];

              searchUpKey = [
                "^[[A"
                "\\eOA"
                "^[OA"
              ];
            };

            initExtraFirst = ''
              touch "${config.home-manager.users.spietras.programs.zsh.history.path}"
            '';

            syntaxHighlighting = {
              enable = true;
            };
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

        xdg = {
          enable = true;
        };
      };
    };
  };
}
