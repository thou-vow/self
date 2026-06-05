(import (
    with (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.flake-parts;
      fetchTarball {
        url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
        sha256 = locked.narHash;
      }
      + "/vendor/flake-compat"
  ) {
    src = ./.;
  }).shellNix
