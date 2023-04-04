{
  inputs,
  directory,
  hosts,
  ...
}: let
  _mkHost = host:
    inputs.utils.mkHost {
      inherit inputs directory host;
    };
  hostConfigs = builtins.map _mkHost hosts;
in
  inputs.utils.mergeAll {
    inherit inputs;
    attrsets = hostConfigs;
  }
