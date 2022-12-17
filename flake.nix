{
  description = "A `flake-parts` module for your Nix devshell scripts";
  inputs = {
    flake-root.url = "github:srid/flake-root";
  };
  outputs = { self, ... }: {
    flakeModule = ./nix/flake-module.nix;
  };
}
