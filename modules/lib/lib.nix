{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = {
    emptyDir = pkgs: pkgs.runCommandCC "empty-dir" {} ''mkdir -p $out '';

    makeExecutable = pkgs: name: path:
      pkgs.runCommand name {} ''
        cp -R ${path} $out
        chmod -R +x $out
      '';

    nixOnDroidConfiguration = pkgs: {modules, ...} @ attrs:
      inputs.nix-on-droid.lib.nixOnDroidConfiguration (
        attrs
        // {
          inherit pkgs;
          modules = modules ++ [self.nixOnDroidModules.core];
        }
      );

    nixosSystem = pkgs: {modules, ...} @ attrs:
      lib.nixosSystem (attrs
        // {
          modules =
            modules
            ++ [
              {nixpkgs = {inherit pkgs;};}
              self.nixosModules.core
            ];
        });
  };
}
