{
  inputs,
  host,
  ...
}: {
  "${inputs.self.nixosConfigurations.${host}.config.nixpkgs.buildPlatform.system}" = {
    "${host}-vm" = inputs.self.nixosConfigurations.${host}.config.system.build.vmWithBootLoader;
  };
}
