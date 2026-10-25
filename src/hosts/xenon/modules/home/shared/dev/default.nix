# Development related stuff
{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    file = lib.mkIf (config.programs.github-copilot-cli.enable && config.programs.github-copilot-cli.settings != {}) {
      # Replace config.json when Copilot overwrites Home Manager's symlink
      # Remove after adopting https://github.com/nix-community/home-manager/pull/10017
      "${config.programs.github-copilot-cli.configDir}/config.json" = {
        force = true;
      };
    };

    sessionVariables = {
      # Disable telemetry for tools that respect this variable
      DO_NOT_TRACK = lib.mkDefault "1";

      # Disable GitHub CLI extension update notices
      GH_NO_EXTENSION_UPDATE_NOTIFIER = lib.mkDefault "1";

      # Disable GitHub CLI update notices
      GH_NO_UPDATE_NOTIFIER = lib.mkDefault "1";

      # Disable automatic copying of selected text in OpenCode
      OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT = lib.mkDefault "true";

      # Use the keyring as the Proton Pass CLI key provider
      PROTON_PASS_KEY_PROVIDER = lib.mkDefault "keyring";

      # Use the kernel keyring for Proton Pass CLI keyring access
      PROTON_PASS_LINUX_KEYRING = lib.mkDefault "kernel";
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

    # OpenCode
    opencode = {
      # Enable integration with configured MCP servers
      enableMcpIntegration = lib.mkDefault true;

      extraPackages = lib.mkDefault [
        # Go toolchain for automatic gopls installation
        pkgs.go

        # Nix language server
        pkgs.nixd

        # Python language server
        pkgs.pyright

        # Rust language server
        pkgs.rust-analyzer
      ];

      settings = {
        # Disable update checks and notices
        autoupdate = lib.mkDefault false;

        compaction = {
          # Remove old tool outputs from context
          prune = lib.mkDefault true;
        };

        # Enable built-in language server integration
        lsp = lib.mkDefault true;

        # Disable automatic workspace snapshots
        snapshot = lib.mkDefault false;
      };
    };
  };
}
