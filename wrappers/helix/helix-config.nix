{
  lib,
  self,
  ...
}: {
  flake.wrappers.helix = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports = [self.wrapperModules.core];

    core.eject.entries = {
      helixSteelConfig = let
        helixScm = pkgs.writeTextFile {
          name = "helix.scm";
          text = config.steel.helixScm;
        };
        initScm = pkgs.writeTextFile {
          name = "init.scm";
          text = config.steel.initScm;
        };
      in
        pkgs.linkFarm "helix-steel-config" ([
            {
              inherit (helixScm) name;
              path = helixScm;
            }
            {
              inherit (initScm) name;
              path = initScm;
            }
          ]
          ++ config.steel.extraPaths);
      helixSteelSearchPaths = pkgs.linkFarm "helix-steel-search-paths" config.steel.cogs;
    };

    env = {
      "HELIX_STEEL_CONFIG" = "${config.core.eject.directory}/${baseNameOf config.core.eject.entries.helixSteelConfig}";
      "STEEL_SEARCH_PATHS" = "${config.core.eject.directory}/${baseNameOf config.core.eject.entries.helixSteelSearchPaths}";
    };

    package = lib.mkDefault inputs'.nix-packages.legacyPackages.helix-steel;
  };

  perSystem = {pkgs, ...}: {
    packages.helix = self.wrappers.helix.wrap {
      inherit pkgs;
      steel = {
        cogs = [
          {
            name = "mattwparas-helix-package";
            path = pkgs.fetchFromGitHub {
              owner = "mattwparas";
              repo = "helix-config";
              rev = "a101da0852932f10792f098dbb14ea88811985ff";
              hash = "sha256-N4Y78H9HDJernQkdH+24tylfl1bleBZewTB7Fk9LlGg=";
            };
          }
          {
            name = "steel-pty";
            path = pkgs.fetchFromGitHub {
              owner = "mattwparas";
              repo = "steel-pty";
              rev = "4d41b6988107b50777d87e587fba7b6b272f069e";
              hash = "sha256-7teIMyLmfPkNEhTFlzmtKaewwwDrlcgmx06prUqXz1g=";
            };
          }
          {
            name = "self";
            path = ./cogs;
          }
        ];
        extraPaths = [
          {
            name = "init";
            path = ./init;
          }
          {
            name = "manual-init.scm";
            path = ./manual-init.scm;
          }
        ];
        initScm =
          # scm
          ''
            (require "manual-init.scm")
          '';
      };
    };
  };

  flake.nixosModules."wrappers.helix" = {
    config,
    self',
    ...
  }: let
    perUser = f:
      config.custom.wrappers.helix.users
      |> lib.mapAttrsToList f
      |> lib.mkMerge;
  in {
    custom.build.wrappers.helix.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.outPackage = let
          package = self'.packages.helix;
        in
          package.wrap {
            inherit (cfg) package;
            steel = lib.mkMerge [package.configuration.steel cfg.steel];
          };
      });

    users.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.packages = [
          config.custom.build.wrappers.helix.users.${name}.outPackage
        ];
      });
  };
}
