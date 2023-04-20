# Create configuration for given formatter
{
  formatter,
  inputs,
  ...
}:
# Create packages for each system
inputs.flake-utils.lib.eachDefaultSystem (
  system: {
    formatter = inputs.nixpkgs.legacyPackages.${system}.${formatter};
  }
)
