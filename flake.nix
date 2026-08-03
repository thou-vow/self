rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://thou-vow-linux.cachix.org"
      "https://nix-community.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:X9yN6WSwyoFihH/tOriqxpaJEP3pd43z8UPmfipvoK8="
      "thou-vow-linux.cachix.org-1:DdL3Lv29JWukrCFnGJrWnfoWMcU3sQ0Js8C1ubd7bXE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  inputs = {
    linux-cachyos-lto-v3.url = "github:thou-vow/linux-cachyos-lto-v3-nix";
    nix-packages.url = "github:thou-vow/nix-packages";
    nixpkgs.follows = "nix-packages/nixpkgs";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      flake = false;
    };
    import-tree = {
      url = "github:denful/import-tree";
      flake = false;
    };
    jail-nix = {
      url = "sourcehut:~alexdavid/jail.nix";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      flake = false;
    };
    preservation = {
      url = "github:nix-community/preservation";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit nixConfig;};
    } ({lib, ...}: {
      imports = [
        (import inputs.import-tree ./self)
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
        };

        systems = lib.systems.flakeExposed;
      };
    });
}
