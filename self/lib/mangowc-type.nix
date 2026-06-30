{lib, ...}: {
  flake.lib = {
    toMangowcAssignments = attrs:
      lib.generators.toKeyValue {
        mkKeyValue = key: value: "${key}=${value}";
        listsAsDuplicateKeys = true;
      }
      attrs;

    types = {
      mangowcValue = with lib.types;
        nullOr (oneOf [
          float
          int
          str
          (listOf (nullOr (oneOf [
            float
            int
            str
          ])))
        ]);
    };
  };
}
