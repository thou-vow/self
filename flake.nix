rec {
  inputs = {
    determinate.follows = "nix-packages/determinate";
    determinate-nix.follows = "nix-packages/determinate-nix";
    flake-parts.follows = "nix-packages/flake-parts";
    impermanence = {
      url = "git+https://github.com/nix-community/impermanence?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.follows = "nix-packages/import-tree";
    nix-packages.url = "git+https://github.com/thou-vow/nix-packages?shallow=1";
    nix-wrapper-modules = {
      url = "git+https://github.com/BirdeeHub/nix-wrapper-modules?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.follows = "nix-packages/nixpkgs";
    nixpkgs-stable.follows = "nix-packages/nixpkgs-stable";
    nyx-loner.follows = "nix-packages/nyx-loner";
    nix-index-database = {
      url = "git+https://github.com/nix-community/nix-index-database?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.follows = "nix-packages/treefmt-nix";
  };

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({lib, ...}: {
      imports = [(inputs.import-tree.filterNot (lib.hasSuffix "flake.nix") ./.)];
      flake = {inherit nixConfig;};
    });
}
