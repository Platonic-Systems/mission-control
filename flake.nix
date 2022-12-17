{
  description = "A `flake-parts` module for your Nix devshell scripts";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-root.url = "github:srid/flake-root";
  };
  outputs = { self, nixpkgs, flake-root, ... }: {
    flakeModule = import ./nix/flake-module.nix { inherit flake-root; };
    templates.default.path = (nixpkgs.lib.cleanSourceWith {
      src = ./example;
      filter = path: type: baseNameOf path == "flake.nix";
    }).outPath;
  };
}
