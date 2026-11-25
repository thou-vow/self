{
  lib,
  self,
  ...
}: {
  flake.homeModules.zsh = {
    config,
    options,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.zsh;
  in {
    options.self.mods.zsh = {
      inherit (options.programs.zsh) package;
      enable = self.lib.mkAutoEnableOption options.programs.zsh.enable;
    };

    config = lib.mkIf cfg.enable {
      home = {
        file."${config.programs.zsh.dotDir}/conf.d/zsh-manual-config.zsh".source = ./zsh-manual-config.zsh;
        packages = with pkgs; [
          pokeget-rs
        ];
      };

      programs.zsh = {
        inherit (cfg) enable package;
        autosuggestion = {
          enable = true;
          strategy = ["match_prev_cmd" "completion"];
        };
        enableCompletion = true;
        initContent =
          # zsh
          ''
            source "$ZDOTDIR"/conf.d/*.zsh(N)
          '';
        syntaxHighlighting.enable = true;
      };
    };
  };
}
