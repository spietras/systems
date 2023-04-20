# Hardware configuration
{config, ...}: {
  hardware = {
    cpu = {
      intel = {
        # Enable updates of the microcode for Intel CPUs
        updateMicrocode = true;
      };
    };

    # Enable additional logging capabilities for hardware
    mcelog = {
      enable = true;
    };

    # Enable emulated devices
    uinput = {
      enable = true;
    };

    # Enable usage for USB modems
    usbWwan = {
      enable = true;
    };

    # This contains especially the allowed frequencies for WiFI in different countries
    wirelessRegulatoryDatabase = true;
  };

  services = {
    # Include a tool for updating the firmware of devices
    fwupd = {
      enable = true;
    };
  };
}
