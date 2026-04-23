{
  inputs,
  lib,
  self,
  ...
}: {
  flake = {
    wrappers.helix.imports = [
      self.wrapperModules.core

      ({
        config,
        inputs',
        pkgs,
        ...
      }: {
        options.steel = {
          cogs = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                };
                path = lib.mkOption {
                  type = lib.types.path;
                };
              };
            });
            default = [];
          };
          extraPaths = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                };
                path = lib.mkOption {
                  type = lib.types.path;
                };
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
          custom.core.eject.entries = {
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
            "HELIX_STEEL_CONFIG" = "${config.custom.core.eject.directory}/${baseNameOf config.custom.core.eject.entries.helixSteelConfig}";
            "STEEL_SEARCH_PATHS" = "${config.custom.core.eject.directory}/${baseNameOf config.custom.core.eject.entries.helixSteelSearchPaths}";
          };

          package = lib.mkDefault inputs'.nix-packages.legacyPackages.helix-steel;
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

    nixosModules."wrappers.helix".options.users.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        imports = [
          (inputs.wrapper-modules.lib.mkInstallModule {
            name = "helix";
            optloc = ["custom" "wrappers"];
            loc = ["packages"];
            value = self.wrapperModules.helix;
          })
        ];
      });
    };
  };
}
