{...}: {
  perSystem = {
    inputs',
    jail,
    pkgs,
    ...
  }: {
    packages = {
      steam-run =
        (pkgs.steam.override {
          extraLibraries = pkgs:
            with pkgs; [
              nspr
              nss
            ];
        }).run-free;

      faugus-launcher = jail "faugus-launcher" inputs'.nix-packages.packages.faugus-launcher (
        with jail.combinators; [
          reset
          base
          fake-passwd
          gui
          gpu
          network
          pipewire
          unsafe-dbus
          unsafe-x11
          wayland
          (readonly "/etc/machine-id")
          (readonly "/nix/store")
          (try-rw-bind (noescape "~/.jail/.config/faugus-launcher") (noescape "~/.config/faugus-launcher"))
          (try-rw-bind (noescape "~/.jail/.local/share/faugus-launcher") (noescape "~/.local/share/faugus-launcher"))
          (try-rw-bind (noescape "~/.jail/.local/share/umu") (noescape "~/.local/share/umu"))
          (try-rw-bind (noescape "~/.jail/Desktop") (noescape "~/Desktop"))
          (try-rw-bind (noescape "~/.jail/Documents") (noescape "~/Documents"))
          (try-rw-bind (noescape "~/.jail/Games") (noescape "~/Games"))
          (try-rw-bind (noescape "~/.jail/Music") (noescape "~/Music"))
          (try-rw-bind (noescape "~/.jail/Pictures") (noescape "~/Pictures"))
          (try-rw-bind (noescape "~/.jail/Prefixes") (noescape "~/Prefixes"))
          (try-rw-bind (noescape "~/.jail/Templates") (noescape "~/Templates"))
          (try-rw-bind (noescape "~/.jail/Videos") (noescape "~/Videos"))
          (try-readonly (noescape "~/.config/gtk-4.0"))
          (try-readonly (noescape "~/.local/share/Steam"))
        ]
      );
    };
  };
}
