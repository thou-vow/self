{
  lib,
  self,
  withSystem,
  ...
}: {
  flake.wrappers.atuin.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.atuin.module = {
    config,
    pkgs,
    ...
  }: let
    tomlFmt = pkgs.formats.toml {};
  in {
    imports = [
      self.wrapperModules.writeFiles
    ];

    options = {
      daemon.enable = lib.mkEnableOption "Atuin daemon";
      settings = lib.mkOption {
        inherit (tomlFmt) type;
        default = {};
      };
    };

    config = {
      envDefault."ATUIN_CONFIG_DIR" =
        self.lib.potentiallyWritableShellInline config.writeFiles.atuinConfig.drv;

      package = lib.mkDefault pkgs.atuin;

      settings = lib.mkIf config.daemon.enable {
        enabled = true;
        autostart = true;
      };

      writeFiles.atuinConfig.entries = {
        "config.toml".subject.source = tomlFmt.generate "config.toml" config.settings;
      };
    };
  };

  flake.wrappers.atuin.integrationModule = {
    options.atuin.initFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  flake.wrappers.atuin.hjemModule = {config, ...}: {
    options.wrappers.atuin.daemon.systemd.enable = lib.mkEnableOption "Atuin systemd units";

    config = {
      systemd = lib.mkIf (config.wrappers.atuin.daemon.enable && config.wrappers.atuin.daemon.systemd.enable) {
        services.atuin-daemon = {
          enable = true;
          description = "Atuin daemon";
          after = ["atuin-daemon.socket"];
          requires = ["atuin-daemon.socket"];
          environment.ATUIN_LOG = "info";
          serviceConfig = {
            ExecStart = "${lib.getExe config.wrappers.atuin.wrapper} daemon start";
            Restart = "on-failure";
            RestartSteps = 3;
            RestartMaxDelaySec = 6;
          };
        };
        sockets.atuin-daemon = {
          enable = true;
          description = "Atuin daemon socket";
          wantedBy = ["sockets.target"];
          socketConfig = {
            ListenStream = "%t/atuin.sock";
            SocketMode = "0600";
            RemoveOnStop = true;
          };
        };
      };

      wrappers.atuin.settings =
        lib.mkIf
        (config.wrappers.atuin.daemon.enable && config.wrappers.atuin.daemon.systemd.enable) {
          autostart = lib.mkOverride 99 false;
          systemd_socket = true;
        };
    };
  };
}
