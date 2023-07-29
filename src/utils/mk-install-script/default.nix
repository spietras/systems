# Create configuration for installer script
# It can be used to install the system on a target machine
# It's defined only for the host system, because you should only run it on the host
{
  host,
  inputs,
  ...
}: {
  "${inputs.self.nixosConfigurations.${host}.config.nixpkgs.buildPlatform.system}" = {
    # The package will have "-install" suffix, for example "nixos-install"
    "${host}-install" = inputs.self.nixosConfigurations.${host}.config.installScript;
  };
}
