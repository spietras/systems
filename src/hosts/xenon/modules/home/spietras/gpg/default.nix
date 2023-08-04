{
  config,
  pkgs,
  ...
}: {
  home-manager = {
    users = {
      spietras = {
        programs = {
          gpg = {
            enable = true;

            # Don't allow to edit keys manually
            mutableKeys = false;

            # Don't allow to edit trust manually
            mutableTrust = false;

            # For some reason, the newer version of GnuPG doesn't work
            package = pkgs.gnupg22.override {
              # However, the older version uses insecure libgcrypt, so we need to change it
              libgcrypt = pkgs.libgcrypt;
            };

            publicKeys = [
              {
                # Take the public key from GitHub
                source = pkgs.fetchurl {
                  url = "https://github.com/spietras.gpg";
                  sha256 = "sha256-axZSBDWxJC6Xm9Q51Mctd9FihOHPQH1PnylwhS5SR30=";
                };

                # This is my key so I trust it fully
                trust = "ultimate";
              }
            ];

            settings = {
              # Disable automatically starting the gpg-agent
              # This ensures that we only use the forwarded agent
              no-autostart = true;
            };
          };

          zsh = {
            # We need to setup the GPG agent socket
            # When connecting to the server, use the socket at /home/spietras/.gnupg/S.gpg-agent
            initExtra = let
              gpgconf = "${config.home-manager.users.spietras.programs.gpg.package}/bin/gpgconf";
              socket = "${config.home-manager.users.spietras.programs.gpg.homedir}/S.gpg-agent";
              ln = "${pkgs.coreutils}/bin/ln";
            in ''
              # Create the socket directory
              ${gpgconf} --create-socketdir

              # Create symbolic link to the socket
              # Run in a subshell to avoid polluting the environment
              (
                TARGET='${socket}'
                LINKNAME="$(${gpgconf} --list-dirs agent-socket)"
                if [ ! -L "$LINKNAME" ]; then
                  ${ln} --symbolic "$TARGET" "$LINKNAME"
                elif [ "$(readlink --canonicalize "$LINKNAME")" != "$TARGET" ]; then
                  ${ln} --symbolic --force --no-dereference "$TARGET" "$LINKNAME"
                fi
              )
            '';
          };
        };
      };
    };
  };
}
