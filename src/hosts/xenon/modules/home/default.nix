# Home Manager configuration
{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./spietras
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
