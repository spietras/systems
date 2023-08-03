{config, ...}: {
  home-manager = {
    users = {
      spietras = {
        programs = {
          starship = {
            enable = true;
            enableZshIntegration = true;
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
      };
    };
  };
}
