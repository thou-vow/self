{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.atuin = {
    config,
    pkgs,
    ...
  }: {
    imports = [self.wrapperModules.core];

    core.eject.entries.atuinConfig = pkgs.linkFarmFromDrvs "atuin-config" [
      (pkgs.writeTextFile {
        name = "config.toml";
        text = inputs.nix-std.lib.serde.toTOML config.settings;
      })
    ];

    env."ATUIN_CONFIG_DIR" = "${config.core.eject.directory}/${baseNameOf config.core.eject.entries.atuinConfig}";

    package = lib.mkDefault pkgs.atuin;
  };

  perSystem = {pkgs, ...}: {
    packages.atuin = self.wrappers.atuin.wrap {
      inherit pkgs;
      settings = {
        inline_height = 9;
        prefers_reduced_motion = true;
        show_help = false;
        show_tabs = false;
        workspaces = true;
      };
    };
  };

  flake.nixosModules."wrappers.atuin" = {
    config,
    self',
    ...
  }: let
    perUser = f:
      config.custom.wrappers.atuin.users
      |> lib.mapAttrsToList f
      |> lib.mkMerge;
  in {
    custom.build.wrappers.atuin.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.outPackage = let
          package = self'.packages.atuin;
        in
          package.wrap {
            settings = lib.mkMerge [
              package.configuration.settings
              (lib.optionalAttrs cfg.daemon.enable {
                daemon = {
                  enabled = true;
                  systemd_socket = true;
                };
              })
              cfg.settings
            ];
          };
      });

    systemd.user = perUser (name: cfg:
      lib.mkIf (cfg.enable && cfg.daemon.enable) {
        services."${name}-atuin-daemon" = {
          enable = true;
          description = "Atuin daemon";
          requires = ["${name}-atuin-daemon.socket"];
          after = ["${name}-atuin-daemon.socket"];
          environment.ATUIN_LOG = "info";
          serviceConfig = {
            ExecStart = "${lib.getExe config.custom.build.wrappers.atuin.users.${name}.outPackage} daemon";
            Restart = "on-failure";
            RestartSteps = 3;
            RestartMaxDelaySec = 6;
          };
          unitConfig.ConditionUser = name;
        };

        sockets."${name}-atuin-daemon" = {
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

    users.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.packages = [
          config.custom.build.wrappers.atuin.users.${name}.outPackage
        ];
      });
  };
}
