{pkgs, ...}: {
  boot = {
    kernelModules = [
      "pcspkr"
    ];
  };

  environment = {
    systemPackages = [
      pkgs.beep
    ];
  };

  services = {
    udev = {
      extraRules = ''
        # Add write access to the PC speaker for the "beep" group
        ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="PC Speaker", ENV{DEVNAME}!="", RUN+="${pkgs.acl}/bin/setfacl -m g:beep:w '$env{DEVNAME}'"
      '';
    };
  };

  users = {
    groups = {
      beep = {
      };
    };
  };
}
