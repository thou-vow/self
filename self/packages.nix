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
          (try-rw-bind (noescape "~/.jail") (noescape "~"))
          (try-readonly (noescape "~/.local/share/Steam"))
        ]
      );
    };
  };
}
