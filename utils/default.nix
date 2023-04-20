{
  mergeAll = import ./merge-all;
  mkInstallScript = import ./mk-install-script;
  mkFormatter = import ./mk-formatter;
  mkHost = import ./mk-host;
  mkHosts = import ./mk-hosts;
  mkNixosConfig = import ./mk-nixos-config;
  mkVmPackage = import ./mk-vm-package;
}
