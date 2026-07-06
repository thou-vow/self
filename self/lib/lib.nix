{lib, ...}: {
  flake.lib = {
    mkAutoEnableOption = name: lib.mkEnableOption name // {default = true;};
  };
}
