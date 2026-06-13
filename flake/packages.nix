{
  inputs,
  lib,
  self,
  ...
} @ top: {
  perSystem = {
    bwrapperLib,
    inputs',
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

        faugus-launcher = bwrapperLib.mkBwrapper {
          app.package = inputs'.nix-packages.packages.faugus-launcher;
          mounts = {
            read = [
              "$HOME/.local/share/Steam"
              "/sys"
            ];
            readWrite = [
              {
                from = "$HOME/.bwrap/home/bwrap";
                to = "$HOME";
              }
            ];
          };
          sockets = {
            pipewire = true;
            pulseaudio = true;
            wayland = true;
          };
        };
      }
    ];
  };
}
