# Users configuration
{config, ...}: {
  users = {
    # Don't allow changing users configuration during runtime
    mutableUsers = false;

    users = {
      root = {
        passwordFile = config.sops.secrets."passwords/root".path;
      };

      spietras = {
        description = "Sebastian Pietras";

        extraGroups = [
          # Can use sudo
          "wheel"
        ];

        isNormalUser = true;
      };
    };
  };
}
