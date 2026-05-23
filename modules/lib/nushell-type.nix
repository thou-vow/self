{
  lib,
  self,
  ...
}: {
  flake.lib = {
    isNushellRaw = lib.isType "nushellRaw";

    mkNushellRaw = value: lib.setType "nushellRaw" {inherit value;};

    nushellRawType = lib.mkOptionType {
      name = "nushellRaw";
      description = "raw Nushell expression";
      descriptionClass = "name";
      check = lib.isType "nushellRaw";
    };

    nushellValueType = let
      valueType = lib.types.nullOr (lib.types.oneOf [
        (self.lib.nushellRawType)
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
        lib.types.path
        (lib.types.attrsOf valueType
          // {
            description = "attribute set of Nushell values";
            descriptionClass = "name";
          })
        (lib.types.listOf valueType
          // {
            description = "list of Nushell values";
            descriptionClass = "name";
          })
      ]);
    in
      valueType;

    toNushell = {...}: expr:
      if expr == null
      then "null"
      else if builtins.isInt expr || builtins.isFloat expr || builtins.isString expr || lib.isBool expr
      then builtins.toJSON expr
      else if builtins.isList expr
      then
        if expr == []
        then "[]"
        else "[ ${lib.pipe expr [
          (map (value: "${self.lib.toNushell {} value}"))
          (lib.concatStringsSep " ")
        ]} ]"
      else if builtins.isAttrs expr
      then
        if self.lib.isNushellRaw expr
        then "(${expr.value})"
        else if lib.isDerivation expr
        then toString expr
        else if expr == {}
        then "{}"
        else "{ ${lib.pipe expr [
          (lib.mapAttrsToList (key: value: "${builtins.toJSON key}: ${self.lib.toNushell {} value}"))
          (lib.concatStringsSep " ")
        ]} }"
      else throw "Unexpected type in toNushell: ${lib.typeOf expr}";
  };
}
