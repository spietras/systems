# Users configuration
{
  config,
  pkgs,
  ...
}: {
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

          # Can use docker
          "docker"

          # Can use beep
          "beep"
        ];

        isNormalUser = true;

        shell = pkgs.zsh;
      };
    };
  };
}
