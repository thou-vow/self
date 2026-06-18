{
  lib,
  self,
  ...
}: {
  flake.lib = {
    isNushellRaw = lib.isType "nushellRaw";

    mkNushellRaw = value: lib.setType "nushellRaw" {inherit value;};

    toNushell = expr:
      if expr == null
      then "null"
      else if lib.isBool expr || builtins.isFloat expr || builtins.isInt expr || builtins.isString expr
      then builtins.toJSON expr
      else if builtins.isList expr
      then "[${lib.pipe expr [
        (map self.lib.toNushell)
        (lib.concatStringsSep " ")
      ]}]"
      else if builtins.isAttrs expr
      then
        if self.lib.isNushellRaw expr
        then "(${expr.value})"
        else if lib.isDerivation expr
        then toString expr
        else "{${lib.pipe expr [
          (lib.mapAttrsToList (key: value: "${builtins.toJSON key}: ${self.lib.toNushell value}"))
          (lib.concatStringsSep " ")
        ]}}"
      else throw "Unexpected type in toNushell: ${lib.typeOf expr}";

    toNushellAssignments = attrs: let
      flattenAttrs = pre: attrs:
        lib.concatMapAttrs (
          name: value:
            if
              builtins.isAttrs value
              && !(self.lib.isNushellRaw value || lib.isDerivation value)
            then flattenAttrs (pre + name + ".") value
            else {${pre + name} = value;}
        )
        attrs;
    in
      (lib.generators.toKeyValue {
        mkKeyValue = key: value: "$$${key} = ${self.lib.toNushell value}";
      }) (flattenAttrs "" attrs);

    types = {
      nushellRaw = lib.mkOptionType {
        name = "nushellRaw";
        description = "raw Nushell expression";
        descriptionClass = "name";
        check = self.lib.isNushellRaw;
      };

      nushellValue = lib.types.nullOr (lib.types.oneOf [
        self.lib.types.nushellRaw
        lib.types.bool
        lib.types.float
        lib.types.int
        lib.types.str
        lib.types.path
        (lib.types.attrsOf self.lib.types.nushellValue
          // {
            description = "attribute set of Nushell values";
            descriptionClass = "name";
          })
        (lib.types.listOf self.lib.types.nushellValue
          // {
            description = "list of Nushell values";
            descriptionClass = "name";
          })
      ]);
    };
  };
}
