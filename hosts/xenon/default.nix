{inputs, ...}: {
  imports = [
    ./modules
    inputs.sops-nix.nixosModules.sops
  ];
}
