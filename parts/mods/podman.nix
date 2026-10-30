{
  lib,
  self,
  ...
}: {
  flake.homeModules.podman = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.podman;
  in {
    options.self.mods.podman = {
      enable = self.lib.mkAutoEnableOption "Podman";
    };

    config = lib.mkIf cfg.enable {
      home.packages = [
        pkgs.podman-compose
      ];

      services.podman = {
        inherit (cfg) enable;
        settings.registries.search = ["docker.io" "ghcr.io" "quay.io"];
      };
    };
  };
}
