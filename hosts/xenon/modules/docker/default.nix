{
  virtualisation = {
    docker = {
      # Enable automatic pruning of old Docker resources
      autoPrune = {
        dates = "Sun, 02:00";
        enable = true;

        flags = [
          # All resources
          "--all"

          # Older than 7 days
          "--filter until=168h"

          # Don't ask for confirmation
          "--force"

          # Include volumes
          "--volumes"
        ];
      };

      daemon = {
        settings = {
          features = {
            # Enable buildkit
            buildkit = true;
          };
        };
      };

      enable = true;
    };
  };
}
