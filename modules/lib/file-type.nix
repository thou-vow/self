{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = let
    fileSubmodule = pkgs: {config, ...}: {
      options = {
        enable = lib.mkEnableOption "this file" // {default = true;};
        drv = lib.mkOption {
          type = lib.types.path;
          default = let
            baseDrv =
              if config.subject ? emptyDir
              then self.lib.emptyDir pkgs
              else if config.subject ? generator
              then config.subject.generator.fn config.subject.generator.value
              else if config.subject ? text
              then
                pkgs.writeTextFile {
                  inherit (config.subject) text;
                  inherit (config) executable name;
                }
              else config.subject.source;
          in
            if (config.executable && (config.subject ? text))
            then self.lib.makeExecutable pkgs config.name baseDrv
            else baseDrv;
        };
        executable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        name = lib.mkOption {
          type = lib.types.nonEmptyStr;
        };
        subject = lib.mkOption {
          type = lib.types.attrTag {
            emptyDir = lib.mkOption {
              type = lib.types.bool;
            };
            generator = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  fn = lib.mkOption {
                    type = lib.types.functionTo (lib.types.either lib.types.lines lib.types.path);
                    description = "Function applied to value to produce a store path.";
                  };
                  value = lib.mkOption {
                    type = lib.types.attrsOf lib.types.anything;
                    description = "Argument passed to fn.";
                  };
                };
              };
              description = "Generate file content from a structured value.";
            };
            text = lib.mkOption {
              type = lib.types.lines;
              description = "Inline text content.";
            };
            source = lib.mkOption {
              type = lib.types.path;
              description = "Path to an existing file or directory.";
            };
          };
        };
      };
    };
  in {
    fileType = pkgs: name:
      lib.types.submoduleWith {
        modules = [
          (fileSubmodule pkgs)
          {name = lib.mkIf (name != null) (lib.mkDefault name);}
        ];
      };

    filesType = pkgs:
      lib.types.attrsOf (lib.types.submoduleWith {
        modules = [
          (fileSubmodule pkgs)
          ({name, ...}: {name = lib.mkDefault name;})
        ];
      });
  };
}
