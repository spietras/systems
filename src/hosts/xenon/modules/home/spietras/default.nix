{pkgs, ...}: {
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

          # TODO: enable shell integration
          broot = {
            enable = true;
          };

          btop = {
            enable = true;
          };

          # TODO: enable shell integration
          direnv = {
            enable = true;

            nix-direnv = {
              enable = true;
            };
          };

          exa = {
            enable = true;
            icons = true; # TODO: fix
          };

          # TODO: enable shell integration
          # TODO: configure (add bat integration)
          fzf = {
            enable = true;
          };

          git = {
            enable = true;

            # TODO: research other diff tools
            delta = {
              enable = true;
            };

            userEmail = "me@spietras.dev";
            userName = "spietras";
          };

          jq = {
            enable = true;
          };

          # TODO: enable shell integration
          keychain = {
            enable = true;
          };

          lazygit = {
            enable = true;
          };

          man = {
            enable = true;
            generateCaches = true;
          };

          # TODO: enable shell integration
          mcfly = {
            enable = true;
          };

          # TODO: enable shell integration
          oh-my-posh = {
            enable = true;
            useTheme = "dracula";
          };

          # TODO: fix downloading cache
          tealdeer = {
            enable = true;
          };

          yt-dlp = {
            enable = true;
          };
        };

        services = {
          # TODO: automatically start daemon
          pueue = {
            enable = true;
          };
        };

        # TODO: environment variables are not set
        xdg = {
          enable = true;

          userDirs = {
            createDirectories = true;
            enable = true;
          };
        };
      };
    };
  };
}
