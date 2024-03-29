{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            nixpkgs-fmt.enable = true;
          };
        };
        mission-control.scripts = {
          fmt = {
            description = "Format all Nix files";
            exec = config.treefmt.build.wrapper;
          };
        };
        devShells.default = pkgs.mkShell {
          # cf. https://zero-to-flakes.com/haskell-flake/devshell#composing-devshells
          inputsFrom = [
            config.mission-control.devShell
            config.treefmt.build.devShell
          ];
        };
      };
    };
}
