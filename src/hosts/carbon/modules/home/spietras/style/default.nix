# Configuration related to styling
{
  programs = {
    firefox = {
      profiles = {
        default = {
          extensions = {
            settings = {
              "FirefoxColor@mozilla.com" = {
                # Override any existing Firefox Color settings
                force = true;
              };
            };
          };
        };
      };
    };
  };

  stylix = {
    targets = {
      firefox = {
        colorTheme = {
          # Enable Firefox Color
          enable = true;
        };

        # Apply styling to default profile
        profileNames = ["default"];
      };
    };
  };
}
