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
        hashedPasswordFile = config.sops.secrets."passwords/root".path;
      };

      spietras = {
        description = "Sebastian Pietras";

        extraGroups = [
          # Can use docker
          config.users.groups.docker.name

          # Can manage printing
          config.users.groups.lpadmin.name

          # Can use tailscale
          config.users.groups.tailscale.name

          # Can use sudo
          config.users.groups.wheel.name
        ];

        hashedPasswordFile = config.sops.secrets."passwords/spietras".path;
        isNormalUser = true;

        # Use zsh as default shell
        shell = pkgs.zsh;

        # Make the UID static so it can be used in other places in the configuration
        uid = 1000;
      };
    };
  };
}
