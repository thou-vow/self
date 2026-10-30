{
  lib,
  self,
  ...
}: {
  flake.homeModules.nushell = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.nushell;
  in {
    options.self.mods.nushell = {
      enable = self.lib.mkAutoEnableOption "Nushell";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nushell;
        description = "The Nushell package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        pokeget-rs
      ];

      programs = {
        carapace.enable = true;

        nushell = {
          inherit (cfg) enable package;
          extraConfig = lib.mkMerge [
            # nu
            ''
              source ./nu-manual-config.nu
            ''
            (lib.mkAfter
              # nu
              ''
                $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
                  ${builtins.concatStringsSep "\n" (map (env:
                  # nu
                  ''
                    ${env}: {
                      from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                      to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                    }
                  '') [
                  "STEEL_SEARCH_PATHS"
                  "TERMINFO_DIRS"
                  "XDG_CONFIG_DIRS"
                  "XDG_DATA_DIRS"
                ])}
                }
              '')
          ];
        };
      };

      xdg.configFile."nushell/nu-manual-config.nu".source = ./nu-manual-config.nu;
    };
  };
}
