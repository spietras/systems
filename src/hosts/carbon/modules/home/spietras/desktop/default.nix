# Desktop environment configuration
{lib, ...}: {
  dconf = {
    settings = {
      "org/gnome/desktop/input-sources" = {
        # Set the default input source to Polish
        sources = lib.gvariant.mkArray [
          (lib.gvariant.mkTuple [
            (lib.gvariant.mkString "xkb")
            (lib.gvariant.mkString "pl")
          ])
        ];
      };

      "org/gnome/desktop/interface" = {
        # Show seconds in the clock
        clock-show-seconds = lib.gvariant.mkBoolean true;
      };

      "org/gnome/desktop/session" = {
        # Set the idle delay to 15 minutes
        idle-delay = lib.gvariant.mkUint32 900;
      };

      "org/gnome/shell/extensions/app-hider" = {
        # Hide some apps
        hidden-apps = lib.gvariant.mkArray [
          (lib.gvariant.mkString "btop.desktop")
          (lib.gvariant.mkString "cups.desktop")
          (lib.gvariant.mkString "epiphany.desktop")
          (lib.gvariant.mkString "kvantummanager.desktop")
          (lib.gvariant.mkString "micro.desktop")
          (lib.gvariant.mkString "nnn.desktop")
          (lib.gvariant.mkString "org.gnome.Console.desktop")
          (lib.gvariant.mkString "org.gnome.Epiphany.desktop")
          (lib.gvariant.mkString "qt5ct.desktop")
          (lib.gvariant.mkString "qt6ct.desktop")
        ];
      };

      "system/locale" = {
        # Set the system locale to Polish
        region = lib.gvariant.mkString "pl_PL.UTF-8";
      };
    };
  };
}
