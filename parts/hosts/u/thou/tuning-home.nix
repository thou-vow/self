{...}: {
  flake.homeModules."thou@u" = {
    inputs',
    pkgs,
    ...
  }: {
    self = {
      dev = {
        nix.packages = [inputs'.nix-packages.packages.nixd-attuned];
        rust.packages = [inputs'.nix-packages.packages.rust-analyzer-attuned];
      };
      mods = {
        helix.package = inputs'.nix-packages.packages.steelix-attuned;
        kitty.package = inputs'.nix-packages.packages.kitty-attuned;
        mango.package = inputs'.nix-packages.packages.mango-attuned;
        noctalia.package = inputs'.nix-packages.packages.noctalia-attuned;
        nushell.package = inputs'.nix-packages.packages.nushell-attuned;
        prismlauncher.package = pkgs.prismlauncher.override {
          glfw3-minecraft = inputs'.nix-packages.packages.glfw-attuned;
        };
      };
    };

    home.packages = with inputs'.nix-packages.packages; [
      llama-prism-attuned
    ];
  };
}
