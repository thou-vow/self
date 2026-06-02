{
  lib,
  self,
  withSystem,
  ...
}: {
  flake.wrappers.atuin.module = {config, ...}: {
    settings = {
      inline_height = 9;
      prefers_reduced_motion = true;
      show_help = false;
      show_tabs = false;
      workspaces = true;
    };
  };

  flake.wrappers.atuin.integrationModule = {config, ...}: {
    atuin.initFlags = ["--disable-up-arrow"];
  };
}
