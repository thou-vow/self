rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://nyx-cache.chaotic.cx/"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
    ];
  };

  inputs = {
    nix-packages.url = "github:thou-vow/nix-packages";
    nixpkgs.follows = "nix-packages/nixpkgs";
    flake-parts.follows = "nix-packages/flake-parts";

    chaotic-nyx = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs = {
        flake-schemas.follows = "flake-schemas";
        home-manager.follows = "";
        jovian.follows = "";
        niks3.follows = "";
        # nixpkgs.follows breaks substituters
        # rust-overlay.follows breaks substituters
      };
    };
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nix-darwin.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs = {
        home-manager.follows = "";
        nix-formatter-pack.follows = "";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-docs.follows = "";
        nixpkgs-for-bootstrap.follows = "";
        nmd.follows = "";
      };
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-nod.url = "github:NixOS/nixpkgs/88d3861acdd3d2f0e361767018218e51810df8a1";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    preservation.url = "github:nix-community/preservation";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      flake = false;
    };
  };

  outputs = inputs: let
    wlib = inputs.nix-wrapper-modules.lib;
  in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit nixConfig wlib;};
    } ({lib, ...}: {
      imports = [
        (import inputs.import-tree ./self)
        ./parts.nix
      ];

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
          pkgs-nod = import inputs.nixpkgs-nod {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };

      systems = lib.systems.flakeExposed;
    });
}
