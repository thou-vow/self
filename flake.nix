rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://thou-vow-linux.cachix.org"
      "https://cache.manic.systems"
      "https://nix-community.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:X9yN6WSwyoFihH/tOriqxpaJEP3pd43z8UPmfipvoK8="
      "thou-vow-linux.cachix.org-1:DdL3Lv29JWukrCFnGJrWnfoWMcU3sQ0Js8C1ubd7bXE="
      "cache.manic.systems-1:s6OZanN8Us8vRi0jVivP3qlMn0cYHBjBALKrNe5nH8s="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  outputs = {self, ...} @ args: let
    inputs = import ./.tack {
      overrides = args.tackOverrides or {};
    };
  in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      self = self // {inherit inputs;};
      specialArgs = {inherit nixConfig;};
    } ({lib, ...}: {
      imports = [
        (import inputs.import-tree ./parts)
        "${inputs.home-manager}/flake-module.nix"
      ];

      options = {
        flake.lib = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.lazyAttrsOf lib.types.raw;
            options = {
              types = lib.mkOption {
                type = lib.types.attrsOf lib.types.raw;
                default = {};
              };
            };
          };
          default = {};
        };
      };

      config = {
        perSystem = {
          inputs',
          pkgs,
          system,
          ...
        }: {
          _module.args = {
            jail = (import inputs.jail-nix {}).init pkgs;

            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          };

          devShells.default = pkgs.mkShell {
            buildInputs =
              [
                inputs'.tack.packages.tack
              ]
              ++ (with pkgs; [
                alejandra
                git
                kdlfmt
                nixd
                schemat
                steel
                taplo
              ]);
          };

          formatter = (import inputs.treefmt-nix).mkWrapper pkgs {
            projectRootFile = "flake.nix";
            programs = {
              alejandra.enable = true;
              kdlfmt.enable = true;
              taplo.enable = true;
            };
            settings.formatter.schemat = {
              command = lib.getExe pkgs.bash;
              options = ["-euc" ''for file in "$@"; do ${lib.getExe pkgs.schemat} $file; done'' "--"];
              includes = ["*.scm"];
            };
          };
        };

        systems = lib.systems.flakeExposed;
      };
    });
}
