{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.starship.module = {
    config,
    pkgs,
    ...
  }: {
  };
}
