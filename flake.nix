{
  description = "homelab configuration";

  inputs = {
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

    impermanence = {
      type = "github";
      owner = "nix-community";
      repo = "impermanence";
      ref = "master";
    };
  };

  outputs = _inputs: let
    inputs = _inputs // {utils = import ./utils;};
  in
    inputs.utils.mkHosts {
      inherit inputs;
      directory = "hosts";
      hosts = ["xenon"];
    };
}
