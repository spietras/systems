# Desktop environment configuration
{lib, ...}: {
  dconf = {
    settings = {
      "org/gnome/desktop/input-sources" = {
        # Set the default input source to Polish
        sources = lib.mkDefault (
          lib.gvariant.mkArray [
            (lib.gvariant.mkTuple [
              (lib.gvariant.mkString "xkb")
              (lib.gvariant.mkString "pl")
            ])
          ]
        );
      };

      "org/gnome/desktop/interface" = {
        # Show seconds in the clock
        clock-show-seconds = lib.mkDefault (lib.gvariant.mkBoolean true);
      };

      "org/gnome/desktop/session" = {
        # Set the idle delay to 15 minutes
        idle-delay = lib.mkDefault (lib.gvariant.mkUint32 900);
      };

      "system/locale" = {
        # Set the system locale to Polish
        region = lib.mkDefault (lib.gvariant.mkString "pl_PL.UTF-8");
      };
    };
  };
}
