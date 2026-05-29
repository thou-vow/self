{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.git.module = {...}: {
    writeFiles.gitConfig.eject.enable = true;
  };
}
