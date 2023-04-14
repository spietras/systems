{
  inputs,
  formatter,
  ...
}:
inputs.flake-utils.lib.eachDefaultSystem (
  system: {
    formatter = inputs.nixpkgs.legacyPackages.${system}.${formatter};
  }
)
