{
  inputs,
  host,
  ...
}: {
  "${inputs.self.nixosConfigurations.${host}.config.nixpkgs.buildPlatform.system}" = {
    "${host}-install" = inputs.self.nixosConfigurations.${host}.config.installScript;
  };
}
