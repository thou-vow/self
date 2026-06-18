{
  lib,
  self,
  ...
}: {
  flake.lib = {
    isSteelRaw = lib.isType "steelRaw";

    isSteelSymbol = lib.isType "steelSymbol";

    isSteelTable = lib.isType "steelTable";

    mkSteelRaw = value: lib.setType "steelRaw" {inherit value;};

    mkSteelSymbol = value: lib.setType "steelSymbol" {inherit value;};

    mkSteelTable = value: lib.setType "steelTable" {inherit value;};

    toSteel = expr:
      if expr == null
      then "'()"
      else if builtins.isBool expr
      then
        if expr
        then "#t"
        else "#f"
      else if builtins.isFloat expr || builtins.isInt expr || builtins.isString expr
      then builtins.toJSON expr
      else if builtins.isList expr
      then
        if expr == []
        then "'()"
        else
          lib.pipe expr [
            (map (self.lib.toSteel))
            toString
            (str: "(list ${str})")
          ]
      else if builtins.isAttrs expr
      then
        if self.lib.isSteelRaw expr
        then expr.value
        else if self.lib.isSteelSymbol expr
        then "'|${lib.escape ["|"] expr.value}|"
        else if self.lib.isSteelTable expr
        then
          lib.pipe expr.value [
            (map (cons: let
              k = builtins.elemAt cons 0;
              v = builtins.elemAt cons 1;
            in "${self.lib.toSteel k} ${self.lib.toSteel v}"))
            toString
            (str: "(hash ${str})")
          ]
        else
          lib.pipe expr [
            (lib.mapAttrsToList (k: v: "${self.lib.toSteel (self.lib.mkSteelSymbol k)} ${self.lib.toSteel v}"))
            toString
            (str: "(hash ${str})")
          ]
      else throw "Unexpected type in toSteel: ${lib.typeOf expr}";

    types = {
      steelRaw = lib.mkOptionType {
        name = "steelRaw";
        description = "raw Steel expression";
        descriptionClass = "name";
        check = self.lib.isSteelRaw;
      };

      steelSymbol = lib.mkOptionType {
        name = "steelSymbol";
        description = "Steel symbol";
        descriptionClass = "name";
        check = self.lib.isSteelSymbol;
      };

      steelTable = lib.mkOptionType {
        name = "steelTable";
        description = "Steel hash table";
        descriptionClass = "name";
        check = self.lib.isSteelTable;
      };

      steelValue = let
        valueType = lib.types.nullOr (lib.types.oneOf [
          self.lib.types.steelRaw
          self.lib.types.steelSymbol
          self.lib.types.steelTable
          lib.types.bool
          lib.types.float
          lib.types.int
          lib.types.str
          (lib.types.attrsOf valueType
            // {
              description = "attribute set of Steel values";
              descriptionClass = "name";
            })
          (lib.types.listOf valueType
            // {
              description = "list of Steel values";
              descriptionClass = "name";
            })
        ]);
      in
        valueType;
    };
  };
}
