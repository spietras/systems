# Applications
{
  config,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
in {
  home = {
    packages = [
      # Bandwidth usage TUI
      pkgs.bandwhich

      # PC Speaker beeps
      pkgs.beep

      # Bluetooth TUI
      pkgs.bluetuith

      # Terminal graphics
      pkgs.chafa

      # Cloudflare Tunnel
      pkgs.cloudflared

      # Displaying CPU information
      pkgs.cpufetch

      # Send files to other devices
      pkgs.croc

      # Containers TUI
      pkgs.ctop

      # curl with httpie syntax
      pkgs.curlie

      # Data manipulation
      pkgs.dasel

      # Display disk usage
      pkgs.duf

      # Better ls
      pkgs.eza

      # Display system information
      pkgs.fastfetch

      # Better find
      pkgs.fd

      # Just ffmpeg
      pkgs.ffmpeg

      # Disk usage analyzer
      pkgs.gdu

      # ImageMagick alternative
      pkgs.graphicsmagick

      # Benchmarking tool
      pkgs.hyperfine

      # Interactive jq playground
      pkgs.jqp

      # Display pokemon sprites
      pkgs.krabby

      # Docker TUI
      pkgs.lazydocker

      # Rainbows
      pkgs.lolcat

      # Minimal text editor
      pkgs.micro

      # Data manipulation
      pkgs.miller

      # There is no spoon
      pkgs.neo

      # Speaking cows
      pkgs.neo-cowsay

      # No more secrets
      pkgs.nms

      # Serve files
      pkgs.nodePackages.serve

      # Colors helper
      pkgs.pastel

      # Cure your bad habit of mistyping
      pkgs.sl

      # Speedtest CLI
      pkgs.speedtest-go

      # sysctl on steroids
      pkgs.systeroid

      # Share the terminal over the web
      pkgs.ttyd

      # Interactive pipe playground
      pkgs.up

      # Secure terminal sharing
      pkgs.upterm

      # Universal SQL client
      pkgs.usql

      # Record terminal sessions as GIFs
      pkgs.vhs

      # HTTPie alternative
      pkgs.xh
    ];

    shellAliases = {
      # Enable icons in eza
      ez = "eza --icons";

      # Run zellij as a systemd service so it's not killed when the terminal is closed
      zj = "systemd-run --user --scope --quiet -- zellij";
    };
  };

  programs = {
    # Better cat
    bat = {
      config = {
        theme = "Visual Studio Dark+";
      };

      enable = true;

      # Enable integration with other programs
      extraPackages = [
        pkgs.bat-extras.batdiff
        pkgs.bat-extras.batgrep
        pkgs.bat-extras.batman
        pkgs.bat-extras.batpipe
        pkgs.bat-extras.batwatch
      ];
    };

    # Navigate directory trees
    broot = {
      enable = true;
      enableZshIntegration = true;
    };

    # Excellent resource monitor
    btop = {
      enable = true;
    };

    # Change shell configuration on the fly
    direnv = {
      enable = true;
      enableZshIntegration = true;

      nix-direnv = {
        # Enable better integration with Nix
        enable = true;
      };
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # JSON processor
    jq = {
      enable = true;
    };

    # Manual
    man = {
      enable = true;

      # Generate page index cache
      generateCaches = true;
    };

    # Smart shell history
    mcfly = {
      enable = true;
      enableZshIntegration = true;
    };

    # File manager
    nnn = {
      enable = true;
    };

    # Better grep
    ripgrep = {
      enable = true;
    };

    # TLDR
    tealdeer = {
      enable = true;

      settings = {
        updates = {
          # Enable automatic updates
          auto_update = true;
        };
      };
    };

    # Google Translate CLI
    translate-shell = {
      enable = true;
    };

    # YouTube downloader
    yt-dlp = {
      enable = true;
    };

    # Modern terminal multiplexer
    zellij = {
      enable = true;
    };

    # Smart cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      shellAliases = {
        # Provide token to cloudflared
        cfd = "TUNNEL_TOKEN=\"$(cat ${config.sops.secrets."cloudflared/token".path})\" TUNNEL_TRANSPORT_PROTOCOL=http2 cloudflared";
      };
    };
  };

  services = {
    # Task scheduler
    pueue = {
      enable = true;
    };
  };
}
