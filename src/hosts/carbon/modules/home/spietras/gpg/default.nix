# GPG configuration
{pkgs, ...}: {
  programs = {
    gpg = {
      # Enable GPG support
      enable = true;

      publicKeys = [
        {
          # Take the public key from GitHub
          source = pkgs.fetchurl {
            sha256 = "sha256-axZSBDWxJC6Xm9Q51Mctd9FihOHPQH1PnylwhS5SR30=";
            url = "https://github.com/spietras.gpg";
          };

          # This is my key so I trust it fully
          trust = "ultimate";
        }
      ];
    };
  };

  services = {
    gpg-agent = {
      # Enable GPG agent
      enable = true;

      # Enable extra GPG agent socket
      enableExtraSocket = true;

      # Enable using GPG agent for SSH
      enableSshSupport = true;

      pinentry = {
        # Use GNOME pinentry
        package = pkgs.pinentry-gnome3;
      };
    };
  };
}
