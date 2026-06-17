{
  lib,
  self,
  ...
} @ top: {
  perSystem = {
    inputs',
    jail,
    pkgs,
    system,
    ...
  }: {
    packages = lib.mkMerge [
      (lib.mapAttrs' (name: value: {
          name = "${name}-wrapper";
          value = self.lib.mkWrapperPackage {
            inherit system;
            wrapper = value;
          };
        })
        top.config.flake.wrappers)
      {
        all-set = self.lib.mkWrappersEnv {
          inherit (self) wrappers;
          inherit system;
          extraIntegrationModules = [
            self.wrapperIntegrationModules.preferences
            {
              preferences.style.palette = sub:
                with sub.config; {
                  main-cursor = "#f4dbe2";
                  other-cursor = "#e8b7c5";

                  dark-background = "#060810";
                  background = "#121622";
                  other-highlight = "#1c2232";
                  main-highlight = "#272d41";
                  other-selection = "#313950";
                  main-selection = "#46516f";
                  invisible = "#7683a8";
                  comment = "#919dbf";
                  dark-foreground = "#aeb8d4";
                  foreground = "#ced4e6";

                  red = "#f0a396";
                  yellow = "#d7b659";
                  green = "#75d18b";
                  cyan = "#60cbdd";
                  blue = "#a4b7f0";
                  magenta = "#e39edc";
                  bright-red = "#f6c9c1";
                  bright-yellow = "#efd387";
                  bright-green = "#99ecaa";
                  bright-cyan = "#95e4f2";
                  bright-blue = "#c8d4f6";
                  bright-magenta = "#eec6e9";

                  escape = red;
                  parameter = yellow;
                  class = green;
                  constant = cyan;
                  function = blue;
                  keyword = magenta;
                  boolean = bright-red;
                  string = bright-yellow;
                  number = bright-green;
                  variable = bright-cyan;
                  namespace = bright-blue;
                  operator = bright-blue;
                  path = bright-magenta;
                };
            }
          ];
        };

        shell-set = self.lib.mkWrappersEnv {
          inherit system;
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              helix
              nushell
              starship
              ;
          };
        };

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
            wayland
            (readonly "/nix/store")
            (try-rw-bind (noescape "~/.jail") (noescape "~"))
            (try-readonly (noescape "~/.local/share/Steam"))
          ]
        );
      }
    ];
  };
}
