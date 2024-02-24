# Secrets configuration
{
  inputs,
  osConfig,
  ...
}: let
  uid = toString osConfig.users.users.spietras.uid;
  runtimeDir = "/run/user/${uid}";
in {
  imports = [
    # Import sops module
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age = {
      # age private keys should be stored at this path on the host
      keyFile = osConfig.constants.secrets.sops.keyFile;
    };

    defaultSopsFile = ./secrets.yaml;

    # Make the paths explicit
    defaultSymlinkPath = "${runtimeDir}/secrets";
    defaultSecretsMountPoint = "${runtimeDir}/secrets.d";

    # You need to explicitly list here all secrets you want to use
    secrets = {
      "cloudflared/token" = {
      };

      "openai/apiKey" = {
      };
    };
  };
}
