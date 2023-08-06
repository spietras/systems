# Nix, NixOS and nixpkgs configuration
{config, ...}: {
  nix = {
    gc = {
      # Enable automatic garbage collection
      automatic = true;

      # Run the garbage collector every day at midnight
      dates = "daily";

      # Delete only generations older than 7 days
      options = "--delete-older-than 7d";
    };

    optimise = {
      # Enable automatic optimisation
      automatic = true;

      # Run the optimisation every day at midnight
      dates = [
        "daily"
      ];
    };

    settings = {
      # Allow wheel and users groups to use nix
      allowed-users = [
        "@wheel"
        "@users"
      ];

      # Enable automatic optimisation
      auto-optimise-store = true;

      # Enable commands and flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs = {
    config = {
      # Allow packages with unfree licenses
      allowUnfree = true;
    };

    # This is needed to specify the architecture of the system
    hostPlatform = config.constants.platform;
  };

  system = {
    # Enable automatic updates
    autoUpgrade = {
      # Check for updates every day at night
      dates = "04:00";

      enable = true;

      # Point to the GitHub repository as the source of truth
      flake = "github:spietras/homelab#${config.constants.name}";

      # Despite the name, this doesn't make the system reboot automatically
      # This only builds the new generation and makes it available at the next boot
      operation = "boot";

      # Don't persist run times
      persistent = false;

      # Introduce some randomness to avoid regular network traffic spikes
      # This means that the update will be checked at a random time between 04:00 and 05:00
      randomizedDelaySec = "1h";
    };

    stateVersion = "22.11";
  };
}
