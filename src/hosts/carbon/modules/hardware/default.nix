# Hardware configuration
{pkgs, ...}: {
  boot = {
    kernelParams = [
      # Enable GuC submission and HuC firmware loading
      "i915.enable_guc=3"
    ];
  };

  environment = {
    sessionVariables = {
      # Specify the VA-API driver
      LIBVA_DRIVER_NAME = "iHD";

      # Specify the VDPAU driver
      VDPAU_DRIVER = "va_gl";
    };
  };

  hardware = {
    bluetooth = {
      # Enable Bluetooth support
      enable = true;
    };

    cpu = {
      intel = {
        # Enable updates of the microcode for Intel CPUs
        updateMicrocode = true;
      };
    };

    # Make all firmware available
    enableAllFirmware = true;

    graphics = {
      # Enable hardware-accelerated rendering
      enable = true;

      extraPackages = [
        # OpenCL and Level Zero runtime
        pkgs.intel-compute-runtime

        # VA-API driver
        pkgs.intel-media-driver

        # VDPAU to VA-API translation layer
        pkgs.libvdpau-va-gl

        # VPL runtime
        pkgs.vpl-gpu-rt
      ];
    };

    logitech = {
      wireless = {
        # Enable support for Logitech wireless devices
        enable = true;

        # Enable graphical support applications
        enableGraphical = true;
      };
    };

    mcelog = {
      # Enable additional logging capabilities for hardware
      enable = true;
    };

    uinput = {
      # Enable emulated devices
      enable = true;
    };

    usb-modeswitch = {
      # Enable usage for USB modems
      enable = true;
    };

    # This contains especially the allowed frequencies for WiFI in different countries
    wirelessRegulatoryDatabase = true;
  };

  services = {
    fwupd = {
      # Include a tool for updating the firmware of devices
      enable = true;
    };
  };
}
