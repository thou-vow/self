{lib, self, ...}: {
  flake.lib = {
    dagLinesType = let
      normalize = value:
        if builtins.isString value
        then {
          name = null;
          data = value;
          before = [];
          after = [];
        }
        else if value ? data
        then {
          inherit (value) data;
          name = value.name or null;
          before = value.before or [];
          after = value.after or [];
        }
        else throw "dagLines: entry must be a string or attrset with data field";

      mergeDefsStep = acc: current:
        if current.name != null && acc.indexTable ? ${current.name}
        then {
          inherit (acc) indexTable;
          list = lib.replaceElemAt acc.list acc.indexTable.${current.name} (
            lib.pipe acc.indexTable.${current.name} [
              (builtins.elemAt acc.list)
              (previous:
                previous
                // {
                  data = previous.data + current.data;
                  before = previous.before ++ current.before;
                  after = previous.after ++ current.after;
                })
            ]
          );
        }
        else {
          indexTable =
            if current.name != null
            then acc.indexTable // {${current.name} = builtins.length acc.list;}
            else acc.indexTable;
          list = acc.list ++ [current];
        };

      mergeDefs = defs:
        lib.pipe defs [
          (map (d: normalize d.value))
          (builtins.foldl' mergeDefsStep {
            list = [];
            indexTable = {};
          })
        ];

      sort = entries: let
        tagged = lib.imap0 (i: entry: entry // {id = entry.name or "_anon-${toString i}";}) entries;
        isBefore = a: b: builtins.elem a.id b.after || builtins.elem b.id a.before;
        sorted = lib.toposort isBefore tagged;
      in
        sorted.result or (throw "dagLines: cycle: ${builtins.toJSON sorted}");
    in
      lib.mkOptionType {
        name = "dagLines";
        descriptionClass = "noun";
        description = "DAG-ordered strings separated by \n";
        merge = _loc: defs: lib.concatStringsSep "\n" (map (e: e.data) (sort (mergeDefs defs).list));
      };

    mkEntryAfter = after: def:
      if builtins.isString def
      then {
        inherit after;
        data = def;
      }
      else def // {after = def.after or [] ++ after;};

    mkEntryBefore = before: def:
      if builtins.isString def
      then {
        inherit before;
        data = def;
      }
      else def // {before = def.before or [] ++ before;};

    mkEntryBetween = after: before: def:
      self.lib.mkEntryBefore before (self.lib.mkEntryAfter after def);

    mkNamedEntry = name: def:
      if builtins.isString def
      then {
        inherit name;
        data = def;
      }
      else def // {inherit name;};

    mkNamedEntryBetween = after: name: before: def:
      self.lib.mkNamedEntry name (self.lib.mkEntryBetween after before def);
  };
}
