{
  lib,
  self,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.atuin = {
      module = {
        config,
        pkgs,
        ...
      }: let
        tomlFmt = pkgs.formats.toml {};
      in {
        imports = [self.wrapperModules.writeFiles];

        options = {
          daemon.enable = lib.mkEnableOption "Atuin daemon";
          settings = lib.mkOption {
            inherit (tomlFmt) type;
            default = {};
          };
        };

        config = {
          envDefault."ATUIN_CONFIG_DIR" = config.writeFiles.atuinConfig.location;

          package = lib.mkDefault pkgs.atuin;

          settings = lib.mkIf config.daemon.enable {
            enabled = true;
            autostart = true;
          };

          writeFiles.atuinConfig = {
            eject.enable = true;
            entries = {
              "config.toml" = lib.mkIf (config.settings != {}) {
                subject.source = tomlFmt.generate "config.toml" config.settings;
              };
            };
          };
        };
      };

      integrationModule = {
        options.atuin.initFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
      };

      nixosUserModule = user: {config, ...}: let
        namespace = ["wrappers" "users" user];
        mk = lib.setAttrByPath (namespace ++ ["atuin"]);
        cfg = lib.attrByPath (namespace ++ ["atuin"]) {} config;
      in {
        options = mk {daemon.systemd.enable = lib.mkEnableOption "Atuin systemd units";};

        config = lib.mkMerge [
          (mk {
            settings = lib.mkIf (cfg.daemon.enable && cfg.daemon.systemd.enable) {
              autostart = lib.mkOverride 99 false;
              systemd_socket = true;
            };
          })
          {
            systemd.user = lib.mkIf (cfg.daemon.enable && cfg.daemon.systemd.enable) {
              services = {
                "${user}-atuin-daemon" = {
                  enable = true;
                  description = "Atuin daemon";
                  after = ["${user}-atuin-daemon.socket"];
                  requires = ["${user}-atuin-daemon.socket"];
                  environment.ATUIN_LOG = "info";
                  serviceConfig = {
                    ExecStart = "${lib.getExe cfg.wrapper} daemon start";
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
      };
    };
  }

  {
    flake.wrappers.atuin = {
      module = {
        settings = {
          inline_height = 9;
          prefers_reduced_motion = true;
          show_help = false;
          show_tabs = false;
          workspaces = true;
        };
      };

      integrationModule = {
        atuin.initFlags = ["--disable-up-arrow"];
      };
    };
  }
]
