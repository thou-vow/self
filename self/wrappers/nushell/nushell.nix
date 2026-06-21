{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.nushell = {
    autoDiscoverModules = "nushell";
    autoDiscoverPresets = "nushell";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.nushell = {pkgs, ...}: {
    configNu = {
      completions =
        wlib.dag.entryAnywhere
        # nu
        ''
          let carapace_completer = {|spans|
            load-env {
             	CARAPACE_SHELL_BUILTINS:
             	  (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
             	CARAPACE_SHELL_FUNCTIONS:
               	(help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
            }
            CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
          }

          $env.config.completions.external.enable = true
          $env.config.completions.external.completer = {|spans|
            let expanded_alias = scope aliases | where name == $spans.0 | $in.0?.expansion?

            let spans = if $expanded_alias != null {
              $spans | skip 1 | prepend ($expanded_alias | split row ' ' | take 1)
            } else { $spans }

            match $spans.0 {
              _ => $carapace_completer
            } | do $in $spans
          }
          $env.config.completions.external.max_results = 9
        '';

      zoxideIntegration = wlib.dag.entryBefore ["shellAliases"] ''
        source ${pkgs.runCommand "zoxide-init-nushell.nu" {}
          "${lib.getExe pkgs.zoxide} init nushell > $out"}
      '';

      manual =
        wlib.dag.entryAfter ["settings"]
        # nu
        ''
          source ($nu.config-path | path dirname | path join 'manual-config.nu')
        '';
    };

    extraConfigFiles = {
      "manual-config.nu".subject.source = ./manual-config.nu;
    };

    runtimePkgs = with pkgs; [
      carapace
      pokeget-rs
      zoxide
    ];

    shellAliases = {
      "cd" = "z";
      "ci" = "zi";
      "e" = "exit";
    };
  };
}
