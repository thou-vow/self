rec {
  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://cache.garnix.io" # nyx-loner
      "https://nix-on-droid.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" # nyx-loner
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nix-packages.url = "github:thou-vow/nix-packages";

    flake-parts.follows = "nix-packages/flake-parts";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    import-tree.follows = "nix-packages/import-tree";
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
    nixpkgs.follows = "nix-packages/nixpkgs";
    nixpkgs-nod.url = "github:NixOS/nixpkgs/88d3861acdd3d2f0e361767018218e51810df8a1";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    treefmt-nix.follows = "nix-packages/treefmt-nix";

    # Packages
    determinate = {
      url = "github:DeterminateSystems/determinate";
      inputs = {
        nix.inputs = {
          # nixpkgs.follows breaks substituters
          nixpkgs-23-11.follows = "nixpkgs";
          nixpkgs-regression.follows = "nixpkgs";
        };
        # nixpkgs.follows breaks substituters
      };
    };
    nyx-loner = {
      url = "github:lonerOrz/nyx-loner";
      inputs = {
        # nixpkgs.follows breaks substituters
        home-manager.follows = "home-manager";
      };
    };

    # Unused/just for deduplication
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit nixConfig;};
    } ({
      self,
      withSystem,
      ...
    }: {
      imports = [
        (inputs.import-tree ./modules)
        ./parts.nix
      ];

      perSystem = {system, ...}: {
        _module.args = {
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
    });
}
