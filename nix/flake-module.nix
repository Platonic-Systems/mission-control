{ self, lib, flake-parts-lib, ... }:
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
                '';
              };
            };
          };

          mainSubmodule = types.submodule {
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
              };
              # Functions
              installToDevShell = mkOption {
                type = types.functionTo types.raw;
                description = lib.mdDoc ''
                  Override the given devshell's shellHook and nativeBuildInputs
                  to add the banner and the wrapper script.
                '';
                default = shell: shell.overrideAttrs (oa:
                  let
                    wrapper = import ./wrapper.nix {
                      inherit pkgs lib;
                      inherit (config) mission-control;
                      flake-root = config.flake-root.package;
                    };
                    banner = import ./banner.nix { inherit wrapper; inherit (config.mission-control) wrapperName; };
                  in
                  {
                    nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ wrapper ];
                    shellHook = (oa.shellHook or "") + banner;
                  });
              };
            };
          };

        in
        {
          options.mission-control = lib.mkOption {
            type = mainSubmodule;
            description = lib.mdDoc ''
              Specification for the scripts in dev shell
            '';
          };
        });
  };
}
