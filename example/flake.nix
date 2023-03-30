{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        mission-control.scripts = {
          hello = {
            description = "Say Hello";
            exec = "echo Hello";
          };
          fmt = {
            description = "Format the top-level Nix files";
            exec = "${lib.getExe pkgs.nixpkgs-fmt} ./*.nix";
            category = "Tools";
          };
          ponysay = {
            exec = pkgs.ponysay;
          };
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ config.mission-control.devShell ];
        };
      };
    };
}
