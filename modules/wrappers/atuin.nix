{
  lib,
  self,
  ...
}: {
  flake.wrappers.atuin = {
    module = lib.mkMerge [
      ({
        config,
        pkgs,
        ...
      }: let
        tomlFmt = pkgs.formats.toml {};
      in {
        imports = [self.wrapperModules.eject];

        options.settings = lib.mkOption {
          inherit (tomlFmt) type;
          default = {};
        };

        config = {
          eject.entries.atuinConfig = pkgs.linkFarm "atuin-config" (
            lib.optionals (config.settings != {}) [
              {
                name = "config.toml";
                path = tomlFmt.generate "config.toml" config.settings;
              }
            ]
          );

          env."ATUIN_CONFIG_DIR" = "${config.eject.directory}/${baseNameOf config.eject.entries.atuinConfig}";

          package = lib.mkDefault pkgs.atuin;
        };
      })

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

    integrationModule = lib.mkMerge [
      {
        options.atuin.initFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      }

      {
        atuin.initFlags = ["--disable-up-arrow"];
      }
    ];

    nixosUserModule = user: let
      namespace = ["wrappers" "users" user];
      mk = lib.setAttrByPath (namespace ++ ["atuin"]);
    in
      lib.mkMerge [
        ({config, ...}: let
          cfg = lib.attrByPath (namespace ++ ["atuin"]) {} config;
        in {
          options = mk {daemon.enable = lib.mkEnableOption "Atuin daemon";};

          config = lib.mkMerge [
            (mk {
              settings = lib.mkIf cfg.daemon.enable {
                enabled = true;
                systemd_socket = true;
              };
            })
            {
              systemd.user = lib.mkIf cfg.daemon.enable {
                services = {
                  "${user}-atuin-daemon" = {
                    enable = true;
                    description = "Atuin daemon";
                    after = ["${user}-atuin-daemon.socket"];
                    requires = ["${user}-atuin-daemon.socket"];
                    environment.ATUIN_LOG = "info";
                    serviceConfig = {
                      ExecStart = "${lib.getExe cfg.wrapper} daemon";
                      Restart = "on-failure";
                      RestartSteps = 3;
                      RestartMaxDelaySec = 6;
                    };
                    unitConfig.ConditionUser = user;
                  };
                };

                sockets = {
                  "${user}-atuin-daemon" = {
                    enable = true;
                    description = "Atuin daemon socket";
                    wantedBy = ["sockets.target"];
                    socketConfig = {
                      ListenStream = "%t/atuin.sock";
                      SocketMode = "0600";
                      RemoveOnStop = true;
                    };
                    unitConfig.ConditionUser = user;
                  };
                };
              };
            }
          ];
        })
      ];
  };
}
