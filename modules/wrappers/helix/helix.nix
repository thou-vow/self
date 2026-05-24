{
  lib,
  self,
  withSystem,
  wlib,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.helix.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.helix.module = {
      config,
      inputs',
      pkgs,
      ...
    }: {
      imports = [
        self.wrapperModules.writeFiles
      ];

      options.steel = {
        cogs = lib.mkOption {
          type = self.lib.filesType pkgs;
          default = {};
        };
        extraConfigFiles = lib.mkOption {
          type = self.lib.filesType pkgs;
          default = {};
        };
        initScm = lib.mkOption {
          type = wlib.types.dagOf lib.types.str;
          default = {};
        };
        helixScm = lib.mkOption {
          type = wlib.types.dagOf lib.types.str;
          default = {};
        };
      };

      config = {
        envDefault = {
          "HELIX_STEEL_CONFIG" = config.writeFiles.helixSteelConfig.location;
          "STEEL_SEARCH_PATHS" = config.writeFiles.helixSteelSearchPaths.location;
        };

        package = lib.mkDefault inputs'.nix-packages.packages.helix-steel;

        writeFiles = {
          helixSteelConfig = {
            eject.enable = true;
            entries = lib.mkMerge [
              {
                "helix.scm" = lib.mkIf (config.steel.helixScm != "") {
                  subject.text = self.lib.convertDagOfStrToLines config.steel.helixScm;
                };
                "init.scm" = lib.mkIf (config.steel.initScm != "") {
                  subject.text = self.lib.convertDagOfStrToLines config.steel.initScm;
                };
              }
              config.steel.extraConfigFiles
            ];
          };
          helixSteelSearchPaths.entries = config.steel.cogs;
        };
      };
    };
  }

  {
    flake.wrappers.helix.module = {pkgs, ...}: {
      steel = {
        cogs = {
          "mattwparas-helix-package".subject.source = pkgs.fetchFromGitHub {
            owner = "mattwparas";
            repo = "helix-config";
            rev = "a101da0852932f10792f098dbb14ea88811985ff";
            hash = "sha256-N4Y78H9HDJernQkdH+24tylfl1bleBZewTB7Fk9LlGg=";
          };
          "self".subject.source = ./cogs;
          "steel-pty".subject.source = pkgs.fetchFromGitHub {
            owner = "mattwparas";
            repo = "steel-pty";
            rev = "4d41b6988107b50777d87e587fba7b6b272f069e";
            hash = "sha256-7teIMyLmfPkNEhTFlzmtKaewwwDrlcgmx06prUqXz1g=";
          };
        };
        extraConfigFiles = {
          "init".subject.source = ./init;
          "manual-init.scm".subject.source = ./manual-init.scm;
        };
        initScm.manual =
          wlib.dag.entryAnywhere
          # scm
          ''
            (require "manual-init.scm")
          '';
      };
    };
  }
]
