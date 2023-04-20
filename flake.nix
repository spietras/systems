{
  description = "homelab configuration";

  inputs = {
    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "main";
    };

    impermanence = {
      type = "github";
      owner = "nix-community";
      repo = "impermanence";
      ref = "master";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
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
  };

  outputs = _inputs: let
    # add custom local inputs
    inputs =
      _inputs
      // {
        packages = import ./packages;
        utils = import ./utils;
      };
    # configuration for all hosts
    hostConfigs = inputs.utils.mkHosts {
      inherit inputs;
      directory = "hosts";
      hosts = ["xenon"];
    };
    # configuration for formatter
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
