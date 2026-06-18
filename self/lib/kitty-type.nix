{lib, ...}: {
  flake.lib = {
    toKittyAssignments = attrs:
      lib.generators.toKeyValue {
        mkKeyValue = key: value: let
          toKitty = expr:
            if expr == null
            then "none"
            else if builtins.isBool expr
            then
              if expr
              then "yes"
              else "no"
            else if builtins.isList expr
            then
              lib.pipe expr [
                (map toKitty)
                (lib.concatStringsSep " ")
              ]
            else toString value;
        in "${key} ${toKitty value}";
      }
      attrs;

    types = {
      kittyValue = lib.types.nullOr (lib.types.oneOf [
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
        (lib.types.listOf
          (lib.types.nullOr (lib.types.oneOf [
            lib.types.bool
            lib.types.float
            lib.types.int
            lib.types.str
          ])))
      ]);
    };
  };
}
