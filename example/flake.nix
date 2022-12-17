{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "path:../.";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit self; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.mission-control.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
        script.scripts = {
          hello = {
            description = "Say Hello";
            command = "echo Hello";
          };
          fmt = {
            description = "Format the Nix files";
            command = "${lib.getExe pkgs.nixpkgs-fmt} ./*.nix ../nix/*.nix";
          };
        };
        devShells.default =
          let shell = pkgs.mkShell { };
          in config.script.installToDevShell shell;
      };
    };
}
