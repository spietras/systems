{config, ...}: {
  home-manager = {
    users = {
      spietras = {
        programs = {
          git = {
            enable = true;

            difftastic = {
              enable = true;
            };

            signing = {
              # Use the configured gpg binary, because by default the one from pkgs is used
              gpgPath = "${config.home-manager.users.spietras.programs.gpg.package}/bin/gpg";

              # Find gpg key by email address
              key = config.home-manager.users.spietras.programs.git.userEmail;

              # Sign commits and tags by default
              signByDefault = true;
            };

            userEmail = "me@spietras.dev";
            userName = "spietras";
          };

          lazygit = {
            enable = true;
          };
        };
      };
    };
  };
}
