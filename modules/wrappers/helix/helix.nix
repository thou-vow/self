{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.helix = {
    module = lib.mkMerge [
      ({
        config,
        inputs',
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.eject];

        options.steel = {
          cogs = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {type = lib.types.str;};
                path = lib.mkOption {type = lib.types.path;};
              };
            });
            default = [];
          };
          extraPaths = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {type = lib.types.str;};
                path = lib.mkOption {type = lib.types.path;};
              };
            });
            default = [];
          };
          initScm = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          helixScm = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
        };

        config = {
          eject.entries = {
            helixSteelConfig = pkgs.linkFarm "helix-steel-config" (
              self.lib.mkLinkFarmOptionalText (config.steel.helixScm != "") {
                inherit pkgs;
                name = "helix.scm";
                text = config.steel.helixScm;
              }
              ++ self.lib.mkLinkFarmOptionalText (config.steel.initScm != "") {
                inherit pkgs;
                name = "init.scm";
                text = config.steel.initScm;
              }
              ++ config.steel.extraPaths
            );
            helixSteelSearchPaths = pkgs.linkFarm "helix-steel-search-paths" config.steel.cogs;
          };

          env = {
            "HELIX_STEEL_CONFIG" = "${config.eject.directory}/${
              baseNameOf config.eject.entries.helixSteelConfig
            }";
            "STEEL_SEARCH_PATHS" = "${config.eject.directory}/${
              baseNameOf config.eject.entries.helixSteelSearchPaths
            }";
          };

          package = lib.mkDefault inputs'.nix-packages.packages.helix-steel;
        };
      })

      ({pkgs, ...}: {
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
      })
    ];
  };
}
