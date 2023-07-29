{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = _inputs: let
    # Add custom local inputs
    inputs =
      _inputs
      // {
        packages = import ./src/packages;
        utils = import ./src/utils;
      };
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      # Import local override if it exists
      imports = [
        (
          if builtins.pathExists ./local.nix
          then ./local.nix
          else {}
        )
      ];

      # System-specific configuration
      flake = inputs.utils.mkHosts {
        inherit inputs;
        directory = "hosts";
        hosts = ["xenon"];
      };

      # Sensible defaults
      systems = [
        "x86_64-linux"
        "i686-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        nil = pkgs.nil;
        task = pkgs.go-task;
        trunk = pkgs.trunk-io;
        # Build copier manually, because the nixpkgs version is outdated
        copier = pkgs.callPackage ./copier.nix {};
        sops = pkgs.sops;
      in {
        # Override pkgs argument
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            # Allow packages with non-free licenses
            allowUnfree = true;
            # Allow packages with broken dependencies
            allowBroken = true;
            # Allow packages with unsupported system
            allowUnsupportedSystem = true;
          };
        };

        # Set which formatter should be used
        formatter = pkgs.alejandra;

        # Define multiple development shells for different purposes
        devShells = {
          default = pkgs.mkShell {
            name = "dev";

            packages = [
              nil
              task
              trunk
              copier
              sops
            ];
          };

          template = pkgs.mkShell {
            name = "template";

            packages = [
              task
              copier
            ];
          };

          flake = pkgs.mkShell {
            name = "flake";

            packages = [
              task
            ];
          };

          lint = pkgs.mkShell {
            name = "lint";

            packages = [
              task
              trunk
            ];
          };
        };
      };
    };
}
