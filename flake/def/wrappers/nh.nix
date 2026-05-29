{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.nh.module = {...}: {
    envDefault.NH_SHOW_ACTIVATION_LOGS = "1";
  };
}
