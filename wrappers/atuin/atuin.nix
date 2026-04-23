{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.atuin.imports = [
    # Support
    self.wrapperModules.core

    # Schema
    ({
      config,
      pkgs,
      ...
    }: {
      options = {
        settings = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
      };

      config = {
        custom.core.eject.entries.atuinConfig = pkgs.linkFarmFromDrvs "atuin-config" [
          (pkgs.writeTextFile {
            name = "config.toml";
            text = inputs.nix-std.lib.serde.toTOML config.settings;
          })
        ];

        env."ATUIN_CONFIG_DIR" = "${config.custom.core.eject.directory}/${
          baseNameOf config.custom.core.eject.entries.atuinConfig
        }";

        package = lib.mkDefault pkgs.atuin;
      };
    })

    # Base defaults
    {
      settings = {
        inline_height = 9;
        prefers_reduced_motion = true;
        show_help = false;
        show_tabs = false;
        workspaces = true;
      };
    }
  ];

  flake.nixosModules."wrappers.atuin".imports = [
    # Support
    {
      options.users.users = let
        subImports = [
          # Support
          (inputs.wrapper-modules.lib.mkInstallModule {
            name = "atuin";
            optloc = ["custom" "wrappers"];
            loc = ["packages"];
            value = self.wrapperModules.atuin;
          })

          # Schema
          (sub: {
            options.custom.wrappers.atuin = {
              daemon.enable = lib.mkEnableOption "Atuin daemon";
              initFlags = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [];
              };
            };

            config.custom.wrappers.atuin.settings =
              lib.mkIf
              sub.config.custom.wrappers.atuin.daemon.enable {
                daemon = {
                  enabled = true;
                  systemd_socket = true;
                };
              };
          })
        ];
      in
        lib.mkOption {type = lib.types.attrsOf (lib.types.submodule {imports = subImports;});};
    }

    # Schema
    ({config, ...}: let
      perUser = f:
        config.users.users
        |> lib.mapAttrsToList f
        |> lib.mkMerge;
    in {
      systemd.user = {
        services = perUser (name: subconfig:
          lib.mkIf (subconfig.custom.wrappers.atuin.enable
            && subconfig.custom.wrappers.atuin.daemon.enable) {
            "${name}-atuin-daemon" = {
              enable = true;
              description = "Atuin daemon";
              after = ["${name}-atuin-daemon.socket"];
              requires = ["${name}-atuin-daemon.socket"];
              environment.ATUIN_LOG = "info";
              serviceConfig = {
                ExecStart = "${lib.getExe subconfig.custom.wrappers.atuin.wrapper} daemon";
                Restart = "on-failure";
                RestartSteps = 3;
                RestartMaxDelaySec = 6;
              };
              unitConfig.ConditionUser = name;
            };
          });

        sockets = perUser (name: subconfig:
          lib.mkIf (subconfig.custom.wrappers.atuin.enable
            && subconfig.custom.wrappers.atuin.daemon.enable) {
            "${name}-atuin-daemon" = {
              enable = true;
              description = "Atuin daemon socket";
              wantedBy = ["sockets.target"];
              socketConfig = {
                ListenStream = "%t/atuin.sock";
                SocketMode = "0600";
                RemoveOnStop = true;
              };
              unitConfig.ConditionUser = name;
            };
          });
      };
    })
  ];
}
