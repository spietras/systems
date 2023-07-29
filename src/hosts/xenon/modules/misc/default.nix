# Options that don't fit in any other category
{
  # Disable unnecessary documentation
  documentation = {
    doc = {
      enable = false;
    };

    info = {
      enable = false;
    };

    nixos = {
      enable = false;
    };
  };

  programs = {
    # Don't give users hints about how to install missing commands
    command-not-found = {
      enable = false;
    };
  };

  services = {
    # Disable logrotate
    logrotate = {
      enable = false;
    };
  };
}
