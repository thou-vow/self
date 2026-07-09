let carapace_completer = {|spans|
  load-env {
   	CARAPACE_SHELL_BUILTINS:
   	  (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
   	CARAPACE_SHELL_FUNCTIONS:
     	(help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
  }
  CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

$env.config.auto_cd_implicit = true;
$env.config.completions.algorithm = "fuzzy"
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
$env.config.footer_mode = "auto"
$env.config.rm.always_trash = true;
$env.config.table.mode = "light"

pokeget random --hide-name
