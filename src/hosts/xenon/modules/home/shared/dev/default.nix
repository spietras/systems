# Development related stuff
{
  lib,
  pkgs,
  ...
}: {
  home = {
    sessionVariables = {
      # Disable telemetry for tools that respect this variable
      DO_NOT_TRACK = lib.mkDefault "1";

      # Disable GitHub CLI extension update notices
      GH_NO_EXTENSION_UPDATE_NOTIFIER = lib.mkDefault "1";

      # Disable GitHub CLI update notices
      GH_NO_UPDATE_NOTIFIER = lib.mkDefault "1";
    };
  };

  programs = {
    # GitHub CLI
    gh = {
      extensions = lib.mkDefault [
        # GitHub TUI dashboard
        pkgs.gh-dash
      ];
    };

    # kubectl colorful output
    kubecolor = {
      # Use kubecolor as the default kubectl client
      enableAlias = lib.mkDefault true;
    };
  };
}
