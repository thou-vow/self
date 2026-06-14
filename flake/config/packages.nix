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
