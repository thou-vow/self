{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.mangowc = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
      wlib.modules.symlinkScript
    ];
  };
}
