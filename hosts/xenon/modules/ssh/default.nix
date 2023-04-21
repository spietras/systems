{
  users = {
    users = {
      spietras = {
        openssh = {
          authorizedKeys = {
            keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOWX2XhWoISt8S57gOx0MJ/rt6I2vP3rsUghHz46dHS"
            ];
          };
        };
      };
    };
  };

  services = {
    openssh = {
      enable = true;

      settings = {
        # Root can't login with SSH
        PermitRootLogin = "no";

        # No one can login with password
        # This means only public key authentication is allowed
        PasswordAuthentication = false;
      };

      # Save resources by only starting the service when needed
      startWhenNeeded = true;
    };

    sshguard = {
      # Prevents brute force attacks
      enable = true;
    };
  };
}
