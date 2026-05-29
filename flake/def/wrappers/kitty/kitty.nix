{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.kitty.module = {
    config,
    wlib,
    ...
  }: {
    extraConfigFiles = {
      "kittens".subject.source = ./kittens;
      "manual-kitty.conf".subject.source = ./manual-kitty.conf;
      "theme.conf".subject.source = ./theme.conf;
    };

    kittyConf.manual = wlib.dag.entryAfter ["settings"] ''
      include ./manual-kitty.conf
    '';

    settings.clear_all_shortcuts = true;

    writeFiles.kittyConfig.eject.enable = true;
  };
}
