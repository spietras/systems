{
  inputs,
  attrsets,
  ...
}: let
  mergeOperator = inputs.nixpkgs.lib.recursiveUpdate;
in
  builtins.foldl' mergeOperator {} attrsets
