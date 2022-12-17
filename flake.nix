{
  description = "A `flake-parts` module for your Nix devshell scripts";
  inputs = {
    flake-root.url = "github:srid/flake-root";
  };
  outputs = { self, flake-root, ... }: {
    flakeModule = import ./nix/flake-module.nix { inherit flake-root; };
  };
}
