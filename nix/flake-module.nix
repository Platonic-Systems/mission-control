{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }:
        let
          scriptSubmodule = types.submodule {
            options = {
              description = mkOption {
                type = types.nullOr types.str;
                description = lib.mdDoc ''
                  A description of what this script does.

                  This will be displayed in the banner and help menu.
                '';
                default = null;
              };
              category = mkOption {
                type = types.str;
                description = lib.mdDoc ''
                  The category under which this script will be gropuped.
                '';
                default = "Commands";
              };
              exec = mkOption {
                type = types.oneOf [ types.str types.package ];
                description = lib.mdDoc ''
                  The script or package to run

                  The $FLAKE_ROOT environment variable will be set to the
                  project root, as determined by the github:srid/flake-root
                  module.
                '';
              };
              cdToProjectRoot = mkOption {
                type = types.bool;
                description = lib.mdDoc ''
                  Whether to change the working directory to the project root
                  before running the script.
                '';
                default = true;
              };
            };
          };

          mainSubmodule = types.submodule ({ config, ... }: {
            options = {
              wrapperName = mkOption {
                type = types.str;
                description = lib.mdDoc ''
                  The name of the wrapper script
                '';
                default = ",";
              };
              scripts = mkOption {
                type = types.attrsOf scriptSubmodule;
                description = lib.mdDoc ''
                  List of scripts to be added to the shell
                '';
                default = { };
              };
              wrapper = mkOption {
                type = types.package;
                description = lib.mdDoc ''
                  The generated wrapper script.
                '';
                default = import ./wrapper.nix {
                  inherit pkgs lib;
                  inherit (config) mission-control;
                  flake-root = config.flake-root.package;
                };
                defaultText = lib.literalMD "generated package";
              };
              banner = mkOption {
                type = types.str;
                description = lib.mdDoc ''
                  The generated shell banner.
                '';
                default = import ./banner.nix { inherit (config.mission-control) wrapper wrapperName; };
                defaultText = lib.literalMD "generated package";
              };
              devShell = mkOption {
                type = types.package;
                description = lib.mdDoc ''
                  A devShell containing the banner and wrapper.
                '';
                readOnly = true;
              };
            };
            config = {
              config.devShell = pkgs.mkShell {
                nativeBuildInputs = [ config.wrapper ];
                shellHook = config.banner;
              };
            };
          });
        in
        {
          options.mission-control = lib.mkOption {
            type = mainSubmodule;
            description = lib.mdDoc ''
              Specification for the scripts in dev shell
            '';
            default = { };
          };
        });
  };
}
