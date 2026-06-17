{
  lib,
  self,
  ...
}: {
  flake.lib = {
    toKittyConf = lib.generators.toKeyValue {
      mkKeyValue = key: value: let
        value' =
          if builtins.isBool value
          then
            if value
            then "yes"
            else "no"
          else toString value;
      in "${key} ${value'}";
    };

    types = {
      kittySettings = lib.types.attrsOf (lib.types.oneOf [
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
      ]);
    };
  };
}
