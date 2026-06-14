{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.writeFiles = {pkgs, ...}: {
    imports = [
      wlib.modules.makeWrapper
    ];

    options.writeFiles = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule ({name, ...} @ farmArgs: {
          options = {
            drv = lib.mkOption {
              readOnly = true;
              type = lib.types.path;
            };
            entries = lib.mkOption {
              type = self.lib.types.files pkgs;
              default = {};
            };
            name = lib.mkOption {
              type = lib.types.nonEmptyStr;
              default = name;
            };
          };

          config.drv = lib.pipe farmArgs.config.entries [
            (lib.mapAttrsToList (name: value: ''
              cp -R ${value.drv} $out/${name} || true
            ''))
            (lib.concatStringsSep "")
            (cmds:
              pkgs.runCommand farmArgs.config.name {} ''
                mkdir -p $out
                ${cmds}
              '')
          ];
        })
      );
    };
  };
}
