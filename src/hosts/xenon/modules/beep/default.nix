# PC Speaker configuration
{
  config,
  pkgs,
  ...
}: {
  boot = {
    initrd = {
      kernelModules = [
        # This kernel module is needed for the PC speaker to work
        "pcspkr"
      ];
    };
  };

  services = {
    udev = {
      extraRules = ''
        # Add write access to the PC speaker for the "beep" group
        ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="PC Speaker", ENV{DEVNAME}!="", RUN+="${pkgs.acl}/bin/setfacl -m g:${config.users.groups.beep.name}:w '$env{DEVNAME}'"
      '';
    };
  };

  users = {
    groups = {
      # Create beep group
      beep = {
      };
    };
  };
}
