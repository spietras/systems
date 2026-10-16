# Development related stuff
{pkgs, ...}: {
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
    };

    # GitHub CLI
    gh = {
      enable = true;
    };

    # GitHub Copilot CLI
    github-copilot-cli = {
      enable = true;
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

    # uv
    uv = {
      enable = true;
    };
  };
}
