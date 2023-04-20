# Configuration related to visual appearance of the system
{
  inputs,
  pkgs,
  ...
}: {
  fonts = {
    fonts = [
      # Emoji font from Google
      pkgs.noto-fonts-emoji

      # Apple fonts
      (pkgs.callPackage inputs.packages.apple-fonts {})
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "SF Pro Text"
        ];

        serif = [
          "New York"
        ];

        # Unpatched font as fallback
        monospace = [
          "SFMono Nerd Font"
          "SF Mono"
        ];

        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };

  services = {
    # Alternative virtual console with hardware rendering
    kmscon = {
      enable = true;
      hwRender = true;
    };
  };
}
