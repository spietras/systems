# Power management configuration
{
  services = {
    logind = {
      settings = {
        Login = {
          # Lock the screen when the lid is closed while on battery
          HandleLidSwitch = "lock";

          # Lock the screen when the lid is closed while on external power
          HandleLidSwitchExternalPower = "lock";

          # Do nothing when the lid is closed while another display is connected
          HandleLidSwitchDocked = "ignore";
        };
      };
    };

    thermald = {
      # Enable temperature management
      enable = true;
    };
  };

  powerManagement = {
    # Enable power management
    enable = true;
  };
}
