{ pkgs, lib, config, flake-root, ... }:

let
  mkCommand = name: v:
    let
      drv = pkgs.writeShellApplication { inherit name; text = if builtins.typeOf v.exec == "string" then v.exec else ''${lib.getExe v.exec} "$@"'';};
    in
    drv.overrideAttrs (oa: {
      meta.description =
        if v.description == null then oa.meta.description or "No description" else v.description;
      meta.category = v.category;
      meta.mainProgram =
        oa.meta.mainProgram or v.name;
    });
  wrapCommands = spec:
    let
      commands = lib.mapAttrsToList mkCommand spec;
      commandsGrouped = lib.groupBy (a: a.meta.category) commands;
    in
    pkgs.writeShellApplication {
      name = config.wrapperName;
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
                      in "  ${config.wrapperName} " + name + "\t: " + desc
                    ) commands 
                    ) + "' | ${lib.getExe pkgs.unixtools.column} -t -s ''$'\t'; "
              ) commandsGrouped)
          }
        }

        # What to do before running the script.
        ${
          lib.concatStringsSep "\n"
            (
              lib.mapAttrsToList (name: v:
                if v.cdToProjectRoot then ''
                  __${name}-prerun () {
                    cd "$FLAKE_ROOT"
                  }
                '' else ''
                  __${name}-prerun () {
                    true
                  }
                ''
              ) spec
            )
        }

        if [ "$*" == "" ] || [ "$*" == "-h" ] || [ "$*" == "--help" ]; then
          showHelp
          exit 0
        else 
          FLAKE_ROOT="''$(${lib.getExe flake-root})"
          export FLAKE_ROOT
          __"$1"-prerun
          exec "$@"
        fi
      '';
    };
  wrapper =
    (wrapCommands config.scripts).overrideAttrs (oa: {
      meta.description = "Development scripts command";
      nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ pkgs.installShellFiles ];
      # TODO: bash and zsh completion
      postInstall = (oa.postInstall or "") + ''
      '';
    });
in
wrapper
