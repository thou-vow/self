{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.niri.imports = [
    # Support
    self.wrapperModules.core

    # Schema
    ({
      config,
      pkgs,
      ...
    }: {
      options = {
        configKdl = lib.mkOption {
          type = lib.types.lines;
          default = "";
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
        xwayland-satellite.package = lib.mkOption {type = lib.types.package;};
      };

      config = {
        custom.core.eject.entries.niriConfig = let
          configKdl = pkgs.writeTextFile {
            name = "config.kdl";
            text = config.configKdl;
          };
        in
          pkgs.linkFarm "niri-config" ([
              {
                inherit (configKdl) name;
                path = configKdl;
              }
            ]
            ++ config.extraPaths);

        drv.installPhase = ''
          runHook preInstall
          ${lib.getExe config.package} validate -c "${config.custom.core.eject.entries.niriConfig}/config.kdl"
          runHook postInstall
        '';

        env."NIRI_CONFIG" = "${config.custom.core.eject.directory}/${baseNameOf config.custom.core.eject.entries.niriConfig}/config.kdl";

        filesToPatch = ["share/systemd/user/niri.service"];

        package = lib.mkDefault pkgs.niri;

        xwayland-satellite.package = lib.mkDefault pkgs.xwayland-satellite;
      };
    })

    # Base defaults
    {
      configKdl = ''
        include "manual-config.kdl"
      '';
      extraPaths = [
        {
          name = "manual-config.kdl";
          path = ./manual-config.kdl;
        }
      ];
    }
  ];

  flake.nixosModules."wrappers.niri".imports = [
    # Support
    {
      options.users.users = let
        subImports = [
          # Support
          (inputs.wrapper-modules.lib.mkInstallModule {
            name = "niri";
            optloc = ["custom" "wrappers"];
            loc = ["packages"];
            value = self.wrapperModules.niri;
          })
        ];
      in
        lib.mkOption {type = lib.types.attrsOf (lib.types.submodule {imports = subImports;});};
    }
  ];
}
