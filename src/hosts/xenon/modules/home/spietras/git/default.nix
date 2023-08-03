{
  home-manager = {
    users = {
      spietras = {
        programs = {
          git = {
            enable = true;

            difftastic = {
              enable = true;
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
