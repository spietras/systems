{config, ...}: {
  sops = {
    defaultSopsFile = ../secrets.yaml;

    age = {
      keyFile = "/${config.constants.storage.partitions.main.datasets.hardstate.label}/sops/age/keys.txt";
    };

    secrets = {
      "passwords/root" = {
        neededForUsers = true;
      };
    };
  };
}
