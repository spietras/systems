# Secrets configuration
{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    age = {
      # age private key should be stored at this path on the host
      keyFile = "/${config.constants.storage.partitions.main.datasets.hardstate.label}/sops/age/keys.txt";
    };

    defaultSopsFile = ../../secrets.yaml;

    # You need to explicitly list here all secrets you want to use
    secrets = {
      "passwords/root" = {
        # This is needed to make the secret available early enough
        neededForUsers = true;
      };
    };
  };
}
