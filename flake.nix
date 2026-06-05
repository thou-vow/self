rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://install.determinate.systems"
      "https://nix-on-droid.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nix-packages.url = "github:thou-vow/nix-packages";

    nixpkgs.follows = "nix-packages/nixpkgs";
    flake-parts.follows = "nix-packages/flake-parts";

    nixpkgs-nod.url = "github:NixOS/nixpkgs/88d3861acdd3d2f0e361767018218e51810df8a1";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    flake-schemas.url = "github:DeterminateSystems/flake-schemas";
    hjem = {
      url = "github:feel-co/hjem";
      inputs = {
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
      };
    };
    import-tree = {
      url = "github:denful/import-tree";
      flake = false;
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        nixpkgs-docs.follows = "nixpkgs";
        nixpkgs-for-bootstrap.follows = "nixpkgs";
      };
    };
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Unused/just for deduplication
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    flake-compat = import "${inputs.flake-parts}/vendor/flake-compat";
    wlib = inputs.nix-wrapper-modules.lib;
  in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit nixConfig wlib;};
    } ({lib, ...}: {
      imports = [
        (import inputs.import-tree ./flake)
        ./parts.nix
      ];

      perSystem = {
        nvfetcherSources,
        pkgs,
        system,
        ...
      }: {
        _module.args = {
          jailInit = import (nvfetcherSources.jail-nix.src).init pkgs;

          nvfetcherFlakes =
            builtins.mapAttrs (_: v: (flake-compat {inherit (v) src;}).outputs)
            {
              inherit
                (nvfetcherSources)
                determinate
                ;
            };
          nvfetcherSources = pkgs.callPackage ./_sources/generated.nix {};

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
