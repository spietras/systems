# SSH client configuration
{lib, ...}: {
  programs = {
    ssh = {
      enableDefaultConfig = false;

      settings = {
        "*" = {
          # Send environment variables to remote host
          sendEnv = lib.mkDefault [
            # Demonstrate color support of client terminal
            "COLORTERM"
          ];
        };
      };
    };
  };
}
