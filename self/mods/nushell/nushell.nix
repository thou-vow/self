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
        carapace
        pokeget-rs
      ];

      programs.nushell = {
        inherit (cfg) enable package;
        extraConfig = lib.mkMerge [
          (lib.mkBefore
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
                "PATH"
                "STEEL_SEARCH_PATHS"
                "TERMINFO_DIRS"
                "XDG_CONFIG_DIRS"
                "XDG_DATA_DIRS"
              ])}
              }
            '')
          (lib.mkAfter
            # nu
            ''
              source ./manual-config.nu
            '')
        ];
      };

      xdg.configFile."nushell/manual-config.nu".source = ./manual-config.nu;
    };
  };
}
