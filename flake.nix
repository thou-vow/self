rec {
  inputs = {
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-packages.url = "github:thou-vow/nix-packages";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
     url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-nod.url = "github:NixOS/nixpkgs/88d3861acdd3d2f0e361767018218e51810df8a1";

    determinate.follows = "nix-packages/determinate";
    determinate-nix.follows = "nix-packages/determinate-nix";
    flake-parts.follows = "nix-packages/flake-parts";
    import-tree.follows = "nix-packages/import-tree";
    nixpkgs.follows = "nix-packages/nixpkgs";
    nixpkgs-stable.follows = "nix-packages/nixpkgs-stable";
    nyx-loner.follows = "nix-packages/nyx-loner";
    treefmt-nix.follows = "nix-packages/treefmt-nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: {
      imports = [(inputs.import-tree.filterNot (lib.hasSuffix "flake.nix") ./.)];
      flake = {inherit nixConfig;};
    });
}
