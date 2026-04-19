{
  lib,
  withSystem,
  ...
}: {
  flake = {
    nixosModules.core = {
      system,
      ...
    }: {
      options.custom.core = {
        flakePath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The absolute path of this flake.";
        };

        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              shellAliases = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
              };
              variables = lib.mkOption {
                type = with lib.types; attrsOf (oneOf [int float path str]);
                default = {};
              };
            };
          });
          default = {};
        };
      };

      config = {
        _module.args = {
          inherit (withSystem system (args: args)) inputs' self';
        };

        nixpkgs.pkgs = withSystem system ({pkgs, ...}: pkgs);
      };
    };

    wrappers.core = {
      config,
      pkgs,
      wlib,
      ...
    }: {
      imports = [wlib.modules.default];

      options.core.eject = {
        directory = lib.mkOption {
          type = lib.types.str;
          default = "\${SELF_EJECT_DIR:-$HOME/.eject}";
        };
        entries = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = {};
        };
      };

      config = {
        _module.args = let
          system = pkgs.stdenv.hostPlatform.system;
        in {
          inherit (withSystem system (args: args)) inputs' self' system;
        };

        escapingFunction = wlib.escapeShellArgWithEnv;

        runShell =
          lib.mapAttrsToList (name: path: let
            entryEjectDir = "${config.core.eject.directory}/${baseNameOf path}";
          in {
            data =
              pkgs.writeScript "${name}-ejector"
              # sh
              ''
                #!${lib.getExe pkgs.dash}
                inputDir=${path}
                ejectDir=${entryEjectDir}
                if [ ! -d "$ejectDir" ]; then
                  mkdir -p "$ejectDir" &&
                  cp -RL "$inputDir"/. "$ejectDir"/ &&
                  chmod -R u+w "$ejectDir"
                fi
              '';
          })
          config.core.eject.entries;
      };
    };
  };
}
