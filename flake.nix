{
  description = "homelab configuration";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
    };

    sops-nix = {
      type = "github";
      owner = "Mic92";
      repo = "sops-nix";
      ref = "master";

      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    impermanence = {
      type = "github";
      owner = "nix-community";
      repo = "impermanence";
      ref = "master";
    };
  };

  outputs = _inputs: let
    inputs = _inputs // {utils = import ./utils;};
    inputs =
      _inputs
      // {
        packages = import ./packages;
        utils = import ./utils;
      };
    hostConfigs = inputs.utils.mkHosts {
      inherit inputs;
      directory = "hosts";
      hosts = ["xenon"];
    };
    formatterConfig = inputs.utils.mkFormatter {
      inherit inputs;
      formatter = "alejandra";
    };
  in
    inputs.utils.mergeAll {
      inherit inputs;
      attrsets = [
        hostConfigs
        formatterConfig
      ];
    };
}
