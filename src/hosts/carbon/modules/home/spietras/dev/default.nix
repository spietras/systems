# Development related stuff
{
  lib,
  pkgs,
  ...
}: {
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

    # uv
    uv = {
      enable = true;

      # Use the latest uv version
      package = pkgs.multiverse.latest.uv;
    };

    # Visual Studio Code
    vscode = {
      enable = true;

      # Use latest VS Code
      package = lib.mkForce pkgs.multiverse.latest.vscode.fhs;
    };
  };
}
