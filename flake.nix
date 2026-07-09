rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nix-packages.url = "github:thou-vow/nix-packages";
    nixpkgs.follows = "nix-packages/nixpkgs";
    flake-parts.follows = "nix-packages/flake-parts";

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
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
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
