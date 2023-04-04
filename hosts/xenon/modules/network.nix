{config, ...}: {
  networking = {
    hostId = config.constants.network.hostId;
    hostName = config.constants.name;
    useDHCP = true;
  };
}
