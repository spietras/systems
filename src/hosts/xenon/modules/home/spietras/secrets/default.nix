# Secrets configuration
{
  config,
  inputs,
  osConfig,
  ...
}: {
  imports = [
    # Import sops modules
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age = {
      # age private keys should be stored at this path on the host
      keyFile = osConfig.constants.secrets.sops.age.file;
    };

    # Store encrypted secrets in this file in the repository
    defaultSopsFile = ./secrets.yaml;

    # You need to explicitly list here all secrets you want to use
    secrets = {
      "cloudflared/token" = {
      };

      "openai/apiKey" = {
      };
    };
  };
}
