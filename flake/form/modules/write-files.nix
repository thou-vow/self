{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.writeFiles = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.makeWrapper
    ];

    options.writeFiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...} @ farmArgs: {
        options = {
          drv = lib.mkOption {
            readOnly = true;
            type = lib.types.path;
          };
          eject = {
            enable = lib.mkEnableOption "ejecting this to a mutable directory";
            target = lib.mkOption {
              type = lib.types.nonEmptyStr;
              default = "\${SELF_EJECT_DIR:-$HOME/.eject}/${baseNameOf farmArgs.config.drv}";
            };
          };
          entries = lib.mkOption {
            type = self.lib.types.files pkgs;
            default = {};
          };
          location = lib.mkOption {
            readOnly = true;
            type = lib.types.nonEmptyStr;
          };
          name = lib.mkOption {
            type = lib.types.nonEmptyStr;
            default = name;
          };
        };

        config = {
          drv = lib.pipe farmArgs.config.entries [
            (lib.mapAttrsToList (_: value: {
              inherit (value) name;
              path = value.drv;
            }))
            (pkgs.linkFarm farmArgs.config.name)
          ];

          location =
            if farmArgs.config.eject.enable
            then farmArgs.config.eject.target
            else "${farmArgs.config.drv}";
        };
      }));
    };

    config = {
      escapingFunction = wlib.escapeShellArgWithEnv;

      runShell = lib.pipe config.writeFiles [
        (lib.filterAttrs (_: value: value.eject.enable))
        (lib.mapAttrsToList (name: value: {
          data =
            pkgs.writeScript "${name}-ejector"
            # sh
            ''
              #!${lib.getExe pkgs.dash}
              drvDir=${value.drv}
              ejectDir=${value.location}
              if [ ! -d "$ejectDir" ]; then
                mkdir -p "$ejectDir" &&
                cp -RL "$drvDir"/. "$ejectDir"/ &&
                chmod -R u+w "$ejectDir"
              fi
            '';
        }))
      ];
    };
  };
}
