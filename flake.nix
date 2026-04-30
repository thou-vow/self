{
  inputs = {
    nix-packages.url = "github:thou-vow/nix-packages";

    nixpkgs.follows = "nix-packages/nixpkgs";
    nixpkgs-stable.follows = "nix-packages/nixpkgs-stable";

    flake-parts.follows = "nix-packages/flake-parts";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.follows = "nix-packages/import-tree";
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.follows = "nix-packages/treefmt-nix";

    determinate.follows = "nix-packages/determinate";
    determinate-nix.follows = "nix-packages/determinate-nix";
    nix-cachyos-kernel.follows = "nix-packages/nix-cachyos-kernel";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

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

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: {
      imports = [(inputs.import-tree.filterNot (lib.hasSuffix "flake.nix") ./.)];
    });
}
