{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.direnv.module = {...}: {
    nix-direnv.enable = true;
    silent = true;

    writeFiles.direnvConfig.eject.enable = true;
  };
}
