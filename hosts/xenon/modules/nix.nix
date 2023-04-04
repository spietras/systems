{config, ...}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
    };
  };

  nixpkgs = {
    hostPlatform = config.constants.platform;
  };

  system = {
    stateVersion = "22.11";
  };
}
