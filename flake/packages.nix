{
  inputs,
  lib,
  self,
  ...
} @ top: {
  perSystem = {
    jailInit,
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
          inherit system;
          wrappers = self.wrappers;
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
      }
    ];
  };
}
