# Configuration related to visual appearance of the system
{
  inputs,
  pkgs,
  ...
}: {
  fonts = {
    packages = [
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

        monospace = [
          "SFMono Nerd Font"

          # Unpatched font as fallback
          "SF Mono"
        ];

        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };

  services = {
    kmscon = {
      # Use alternative virtual console
      enable = true;

      # Enable hardware rendering
      hwRender = true;
    };
  };
}
