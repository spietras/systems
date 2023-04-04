{
  inputs,
  directory,
  host,
  ...
}: {
  "${host}" = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {inherit inputs;};
    modules = [(./. + "/../${directory}/${host}")];
  };
}
