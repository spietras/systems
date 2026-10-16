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

    # GitHub Copilot CLI
    github-copilot-cli = {
      # Enable integration with configured MCP servers
      enableMcpIntegration = lib.mkDefault true;

      settings = {
        # Disable automatic updates
        autoUpdate = lib.mkDefault false;

        # Use high reasoning effort
        effortLevel = lib.mkDefault "high";

        # Do not add Copilot as a commit co-author
        includeCoAuthoredBy = lib.mkDefault false;

        # Keep the system awake while Copilot is working
        keepAlive = lib.mkDefault "busy";

        sandbox = {
          # Enable sandboxing
          enabled = lib.mkDefault true;

          userPolicy = {
            network = {
              # Allow sandboxed processes to access the local network
              allowLocalNetwork = lib.mkDefault true;
            };
          };
        };
      };
    };

    # kubectl colorful output
    kubecolor = {
      # Use kubecolor as the default kubectl client
      enableAlias = lib.mkDefault true;
    };
  };
}
