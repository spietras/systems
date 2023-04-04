{config, ...}: {
  users = {
    mutableUsers = false;

    users = {
      root = {
        passwordFile = config.sops.secrets."passwords/root".path;
      };

      spietras = {
        isNormalUser = true;
        extraGroups = ["wheel"];
      };
    };
  };
}
