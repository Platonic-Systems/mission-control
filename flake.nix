{
  description = "A `flake-parts` module for your Nix devshell scripts";
  outputs = { self, ... }: {
    flakeModule = ./nix/flake-module.nix;
  };
}
