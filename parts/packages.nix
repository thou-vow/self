{...}: {
  perSystem = {
    inputs',
    jail,
    pkgs,
    system,
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
          (try-rw-bind (noescape "~/.jail/Downloads") (noescape "~/Downloads"))
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

      graalvm-oracle_25i = inputs'.nix-packages.packages.graalvm-oracle_25.overrideAttrs {
        version = "25i4-25.0.4.1.1";
        src = builtins.getAttr system {
          aarch64-linux = pkgs.fetchurl {
            url = "https://gds.oracle.com/download/graal/25i4/archive/graalvm-jdk-25i4-25.0.4.1.1_linux-aarch64_bin.tar.gz";
            sha256 = "sha256-eA1XhNPbm7z/d3dcTQJuSg4hoEG6nbp8WRNZSepSNKQ=";
          };
          x86_64-linux = pkgs.fetchurl {
            url = "https://gds.oracle.com/download/graal/25i4/archive/graalvm-jdk-25i4-25.0.4.1.1_linux-x64_bin.tar.gz";
            sha256 = "sha256-T8xjLPxo6Y9J+TFvijWIuv5PUonxIBBOLSkKdc8z4o4=";
          };
        };
      };
    };
  };
}
