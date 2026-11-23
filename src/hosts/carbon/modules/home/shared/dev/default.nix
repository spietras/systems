# Development related stuff
{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    file = {
      # Let Docker manage its config
      "${config.programs.docker-cli.configDir}/config.json" = {
        enable = false;
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

      # Use D-Bus for Proton Pass CLI keyring access
      PROTON_PASS_LINUX_KEYRING = lib.mkDefault "dbus";
    };
  };

  programs = {
    # Claude Code
    claude-code = {
      # Use configured MCP servers
      enableMcpIntegration = lib.mkDefault true;

      rules = {
        tools = ''
          # Tools available globally

          - docker
          - nh
          - nix
        '';
      };

      settings = {
        # Disable attribution
        attribution = {
          commit = lib.mkDefault "";
          pr = lib.mkDefault "";
          sessionUrl = lib.mkDefault false;
        };

        # Use high reasoning effort
        effortLevel = lib.mkDefault "high";

        env = {
          # Reset the working directory after each command
          CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR = lib.mkDefault "1";

          # Disable nonessential traffic
          CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = lib.mkDefault "1";

          # Skip IDE extension installation
          CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL = lib.mkDefault "1";

          # Limit concurrent subagents
          CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS = lib.mkDefault "4";

          # Run initialization interactively
          CLAUDE_CODE_NEW_INIT = lib.mkDefault "true";

          # Default subagents to Haiku
          CLAUDE_CODE_SUBAGENT_MODEL = lib.mkDefault "haiku";

          # Disable the feedback command
          DISABLE_FEEDBACK_COMMAND = lib.mkDefault "1";

          # Disable installation warnings
          DISABLE_INSTALLATION_CHECKS = lib.mkDefault "1";

          # Keep automatic plugin updates
          FORCE_AUTOUPDATE_PLUGINS = lib.mkDefault "1";
        };

        # Disable Git instructions and initial status
        includeGitInstructions = lib.mkDefault false;

        # Use Sonnet by default
        model = lib.mkDefault "sonnet";

        permissions = {
          # Use classifier-based approvals
          defaultMode = lib.mkDefault "auto";

          # Disable bypass mode
          disableBypassPermissionsMode = lib.mkDefault "disable";
        };

        sandbox = {
          # Allow unsandboxed retries
          allowUnsandboxedCommands = lib.mkDefault true;

          # Check permissions for sandboxed commands
          autoAllowBashIfSandboxed = lib.mkDefault false;

          # Enable sandboxing
          enabled = lib.mkDefault true;

          # Require a working sandbox
          failIfUnavailable = lib.mkDefault true;

          filesystem = {
            allowWrite = lib.mkDefault [
              # GitHub CLI config
              "${config.xdg.configHome}/gh"

              # GPG locks for signing
              config.programs.gpg.homedir

              # Tool caches
              config.xdg.cacheHome

              # Bun cache and global packages
              "${config.home.homeDirectory}/.bun"

              # npm cache
              "${config.home.homeDirectory}/.npm"

              # uv Python installs and tools
              "${config.xdg.dataHome}/uv"
            ];

            denyWrite = lib.mkDefault [
              # Protect GPG config and keys
              "${config.programs.gpg.homedir}/common.conf"
              "${config.programs.gpg.homedir}/dirmngr.conf"
              "${config.programs.gpg.homedir}/gpg-agent.conf"
              "${config.programs.gpg.homedir}/gpg.conf"
              "${config.programs.gpg.homedir}/gpgconf.conf"
              "${config.programs.gpg.homedir}/gpgsm.conf"
              "${config.programs.gpg.homedir}/keyboxd.conf"
              "${config.programs.gpg.homedir}/openpgp-revocs.d"
              "${config.programs.gpg.homedir}/private-keys-v1.d"
              "${config.programs.gpg.homedir}/pubring.gpg"
              "${config.programs.gpg.homedir}/pubring.kbx"
              "${config.programs.gpg.homedir}/public-keys.d"
              "${config.programs.gpg.homedir}/scdaemon.conf"
              "${config.programs.gpg.homedir}/secring.gpg"
              "${config.programs.gpg.homedir}/sshcontrol"
              "${config.programs.gpg.homedir}/trustlist.txt"
            ];
          };

          network = {
            # Allow sockets for Nix, GPG, and SSH
            allowAllUnixSockets = lib.mkDefault true;

            allowedDomains = lib.mkDefault [
              # GitHub
              "api.github.com"
              "github.com"

              # PyPI
              "files.pythonhosted.org"
              "pypi.org"

              # npm registry
              "registry.npmjs.org"
            ];
          };
        };

        # Use ccstatusline
        statusLine = {
          command = lib.mkDefault "${config.programs.bun.package}/bin/bunx ccstatusline@2.2.34";
          type = lib.mkDefault "command";
        };

        # Use the classic interface
        tui = lib.mkDefault "default";
      };
    };

    # Docker CLI config
    docker-cli = {
      configDir = lib.mkDefault "${config.xdg.configHome}/docker";
    };

    # GitHub CLI
    gh = {
      extensions = lib.mkDefault [
        # GitHub TUI dashboard
        pkgs.gh-dash
      ];

      settings = {
        # Disable telemetry
        telemetry = lib.mkDefault "disabled";
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

      tui = {
        attention = {
          # Enable attention notifications and sounds
          enabled = lib.mkDefault true;
        };
      };
    };

    # Visual Studio Code
    vscode = {
      # Use the FHS-wrapped package so extensions with pre-built binaries can be used
      package = pkgs.vscode.fhs;
    };
  };
}
