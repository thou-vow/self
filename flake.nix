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
    nix-std.url = "github:chessai/nix-std";
    treefmt-nix.follows = "nix-packages/treefmt-nix";
    wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.follows = "nix-packages/determinate";
    determinate-nix.follows = "nix-packages/determinate-nix";
    niri-flake.follows = "nix-packages/niri-flake";
    nix-cachyos-kernel.follows = "nix-packages/nix-cachyos-kernel";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://thou-vow.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
      "https://install.determinate.systems"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "thou-vow.cachix.org-1:n6zUvWYOI7kh0jgd+ghWhxeMd9tVdYF2KdOvufJ/Qy4="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      lib,
      self,
      ...
    }: {
      imports = let
        isPartsModule = file:
          file.hasExt "nix"
          && file.name != "flake.nix"
          && !lib.hasPrefix "_" file.name;
      in
        (./.
          |> lib.fileset.fileFilter isPartsModule
          |> lib.fileset.toList)
        ++ [
          inputs.wrapper-modules.flakeModules.wrappers
        ];

      flake.nixosConfigurations.u = lib.nixosSystem {
        modules = [self.nixosModules."hosts.u"];
        specialArgs = {system = "x86_64-linux";};
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [alejandra kdlfmt schemat taplo];
        };

        formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
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

        wrappers.control_type = "build";
      };

      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    });
}
