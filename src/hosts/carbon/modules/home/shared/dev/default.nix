# Development related stuff
{
  lib,
  pkgs,
  ...
}: {
  programs = {
    # kubectl colorful output
    kubecolor = {
      # Use kubecolor as the default kubectl client
      enableAlias = lib.mkDefault true;
    };

    # Visual Studio Code
    vscode = {
      # Use the FHS-wrapped package so extensions with pre-built binaries can be used
      package = pkgs.vscode.fhs;
    };
  };
}
