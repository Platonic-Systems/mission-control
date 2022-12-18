{
  description = "A `flake-parts` module for your Nix devshell scripts";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, ... }: {
    flakeModule = ./nix/flake-module.nix;
    templates.default.path = (nixpkgs.lib.cleanSourceWith {
      src = ./example;
      filter = path: type: baseNameOf path == "flake.nix";
    }).outPath;
  };
}
