{
  lib,
  inputs,
  nixConfig,
  ...
} @ top: {
  flake = {
    nixOnDroidModules.nix = {
      config,
      inputs',
      ...
    }: {
      nix = {
        extraOptions = let
          inherit (nixConfig) extra-substituters extra-trusted-public-keys;
        in
          lib.mkMerge [
            ''
              extra-experimental-features = flakes nix-command
              keep-derivations = true
              keep-outputs = true
            ''
            (lib.mkIf (extra-substituters != []) ''
              extra-substituters = ${toString extra-substituters}
            '')
            (lib.mkIf (extra-trusted-public-keys != []) ''
              extra-trusted-public-keys = ${toString extra-trusted-public-keys}
            '')
          ];

        nixPath =
          lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

        registry = lib.mkMerge [
          (lib.pipe inputs [
            (lib.filterAttrs (_: value: lib.isType "flake" value))
            (lib.mapAttrs (_: value: {flake = value;}))
          ])
          {
            nixpkgs-master.to = {
              type = "github";
              owner = "nixos";
              repo = "nixpkgs";
            };
            self.to = lib.mkIf (config.ext.state.flakePath or null != null) {
              type = "git";
              url = "file://${config.ext.state.flakePath}";
            };
          }
        ];
      };
    };

    nixosModules.nix = {
      config,
      inputs',
      ...
    }: {
      imports = [inputs.determinate.nixosModules.default];

      options.ext.nix = {
        determinate = {
          enable = lib.mkEnableOption "Determinate Nix";
        };
      };

      config = {
        determinate.enable = config.ext.nix.determinate.enable;

        environment.variables.DETSYS_IDS_TELEMETRY =
          lib.mkIf config.ext.nix.determinate.enable "disabled";

        nix = {
          daemonCPUSchedPolicy = "idle";
          daemonIOSchedClass = "idle";

          nixPath =
            lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

          registry = lib.mkMerge [
            (lib.pipe inputs [
              (lib.filterAttrs (_: value: lib.isType "flake" value))
              (lib.mapAttrs (_: value: {flake = value;}))
            ])
            {
              nixpkgs-master.to = {
                type = "github";
                owner = "nixos";
                repo = "nixpkgs";
              };
              self.to = lib.mkIf (config.ext.state.flakePath or null != null) {
                type = "git";
                url = "file://${config.ext.state.flakePath}";
              };
            }
          ];

          settings = {
            inherit (nixConfig) extra-substituters extra-trusted-public-keys;
            extra-experimental-features = ["flakes" "nix-command"];
            keep-derivations = true;
            keep-outputs = true;
            trusted-users = ["@wheel"];
          };
        };
      };
    };
  };
}
