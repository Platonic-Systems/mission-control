{ pkgs, lib, mission-control, flake-root, ... }:

let
  mkCommand = name: v:
    let
      drv =
        if v.package == null
        then pkgs.writeShellApplication { inherit name; text = v.command; }
        else
          if v.command == null
          then v.package
          else builtins.throw "misson-control.scripts.${name}: Both 'package' and 'command' options are set. You must set exactly one of them.";
    in
    drv.overrideAttrs (oa: {
      meta.description =
        if v.description == null then oa.meta.description or "No description" else v.description;
      meta.category = v.category;
    });
  wrapCommands = spec:
    let
      commands = lib.mapAttrsToList mkCommand spec;
      commandsGrouped = lib.groupBy (a: a.meta.category) commands;
    in
    pkgs.writeShellApplication {
      name = mission-control.wrapperName;
      runtimeInputs = commands;
      text = ''
        showHelp () {
          echo -e "Available commands:\n"
          ${
            lib.concatStringsSep "echo;"
              (lib.mapAttrsToList (cat: commands: 
                "echo -e '## " + cat + "';echo;" + 
                  "echo '" + lib.concatStringsSep "\n" 
                    (map (drv: 
                      let name = builtins.baseNameOf (lib.getExe drv);
                          desc = drv.meta.description;
                      in "  ${mission-control.wrapperName} " + name + "\t: " + desc
                    ) commands 
                    ) + "' | ${lib.getExe pkgs.unixtools.column} -t -s ''$'\t'; "
              ) commandsGrouped)
          }
        }
        if [ "$*" == "" ] || [ "$*" == "-h" ] || [ "$*" == "--help" ]; then
          showHelp
          exit 1
        else 
          FLAKE_ROOT="''$(${lib.getExe flake-root})"
          cd "$FLAKE_ROOT"
          exec "$@"
        fi
      '';
    };
  wrapper =
    (wrapCommands mission-control.scripts).overrideAttrs (oa: {
      meta.description = "Development scripts command";
      nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ pkgs.installShellFiles ];
      # TODO: bash and zsh completion
      postInstall = (oa.postInstall or "") + ''
      '';
    });
in
wrapper
