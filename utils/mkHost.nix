{
  inputs,
  directory,
  host,
  ...
}: {
  nixosConfigurations = inputs.utils.mkNixosConfig {inherit inputs directory host;};
  packages = inputs.nixpkgs.lib.recursiveUpdate (inputs.utils.mkVmPackage {inherit inputs host;}) (inputs.utils.mkInstallScript {inherit inputs host;});
}
