# Development related stuff
{pkgs, ...}: let
  jsonFormat = pkgs.formats.json {};
in {
  home = {
    packages = [
      # Containers TUI
      pkgs.ctop

      # Docker image inspector
      pkgs.dive

      # Dockerfile linter
      pkgs.hadolint

      # Google Cloud SDK
      pkgs.google-cloud-sdk

      # Google Workspace CLI
      pkgs.gws

      # Nix language server
      pkgs.nil

      # NodeJS
      pkgs.nodejs

      # Python
      pkgs.python3
    ];
  };

  programs = {
    # Bun
    bun = {
      enable = true;

      # Use the latest Bun version
      package = pkgs.multiverse.latest.bun;
    };

    # GitHub CLI
    gh = {
      enable = true;

      extensions = [
        # GitHub TUI dashboard
        pkgs.multiverse.latest.gh-dash
      ];

      # Use the latest GitHub CLI version
      package = pkgs.multiverse.latest.gh;
    };

    # GitHub Copilot CLI
    github-copilot-cli = {
      enable = true;

      # Use the latest GitHub Copilot CLI version
      package = pkgs.multiverse.latest.github-copilot-cli;
    };

    # Kubernetes TUI
    k9s = {
      enable = true;
    };

    # kubectl colorful output
    kubecolor = {
      enable = true;
    };

    # Kubernetes context switching
    kubeswitch = {
      enable = true;
    };

    # OpenCode
    opencode = {
      enable = true;

      # Use the latest OpenCode version
      package = pkgs.multiverse.latest.opencode;

      settings = {
        plugin = [
          # Enable subscription quota reporting
          "@slkiser/opencode-quota@4"
        ];
      };

      tui = {
        plugin = [
          # Enable subscription quota reporting
          "@slkiser/opencode-quota@4"
        ];
      };
    };

    # uv
    uv = {
      enable = true;

      # Use the latest uv version
      package = pkgs.multiverse.latest.uv;
    };
  };

  xdg = {
    configFile = {
      "opencode/opencode-quota/quota-toast.json" = {
        source = jsonFormat.generate "quota-toast.json" {
          # Disable quota popups
          enableToast = false;

          enabledProviders = [
            # Show OpenAI subscription quotas
            "openai"
          ];

          # Show all quota windows in reports
          formatStyle = "allWindows";

          maintainerAnnouncements = {
            # Disable maintainer announcements
            enabled = false;
          };

          # Display used quota instead of remaining quota
          percentDisplayMode = "used";

          tuiPromptBar = {
            # Show quota usage as a progress bar
            enabled = true;
          };
        };
      };
    };
  };
}
