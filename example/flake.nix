{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.mission-control.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        mission-control.scripts = {
          hello = {
            description = "Say Hello";
            command = "echo Hello";
          };
          fmt = {
            description = "Format the Nix files";
            command = "${lib.getExe pkgs.nixpkgs-fmt} ./*.nix ../nix/*.nix";
            category = "Tools";
          };
        };
        devShells.default =
          let shell = pkgs.mkShell { };
          in config.mission-control.installToDevShell shell;
      };
    };
}
