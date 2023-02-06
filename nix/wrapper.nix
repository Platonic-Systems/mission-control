{ pkgs, lib, mission-control, flake-root, withShellCompletions ? true, ... }:

let
  inherit (mission-control) wrapperName;
  commandNames = lib.attrNames mission-control.scripts;
  mkCommand = name: v:
    let
      drv =
        if builtins.typeOf v.exec == "string"
        then pkgs.writeShellApplication { inherit name; text = v.exec; }
        else v.exec;
    in
    drv.overrideAttrs (oa: {
      meta.description =
        if v.description == null then oa.meta.description or "No description" else v.description;
      meta.category = v.category;
    });
  wrapCommands =
    let
      commands = lib.mapAttrsToList mkCommand mission-control.scripts;
      commandsGrouped = lib.groupBy (a: a.meta.category) commands;
    in
    pkgs.writeShellApplication {
      name = wrapperName;
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
  sanitizedWrapperName =
    builtins.replaceStrings
      [ "," ]
      [ "__comma__" ]
      wrapperName;
  quotedPrependNotEmpty = s: x:
    if x == null then "" else lib.strings.optionalString (x != "") ''${s} "${x}"'';
  bashCompletions = pkgs.writeText "${wrapperName}-completions.bash" ''
    complete -o bashdefault -o default -F _${sanitizedWrapperName} ${wrapperName}

    _${sanitizedWrapperName}() {
      if [ "$COMP_CWORD" -eq "1" ]; then
        local cur="''${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY=($(compgen -W "${toString commandNames}" -- "$cur"))
      else 
        COMPREPLY=()
      fi
    }
  '';
  fishCompletions = pkgs.writeText "${wrapperName}-completions.fish" ''
    function __fish_${sanitizedWrapperName}_no_subcommand --description "Test if ${wrapperName} has yet to be given a subcommand"
      for i in (commandline -opc)
        if contains -- $i ${lib.strings.concatStringsSep " " commandNames}
          return 1
        end
      end
      return 0
    end

    complete --command "${wrapperName}" --condition "__fish_${sanitizedWrapperName}_no_subcommand" --no-files --short-option "h" --long-option "help" --description "Print help text"
    ${lib.pipe mission-control.scripts [
      (lib.mapAttrsToList (name: { description, ... }: ''
        complete --command "${wrapperName}" --no-files --condition "__fish_${sanitizedWrapperName}_no_subcommand" --arguments "${name}"${quotedPrependNotEmpty " --description " description}
        complete --command "${wrapperName}" --force-files --condition "__fish_seen_subcommand_from ${name}"
      ''))
      (lib.strings.concatStringsSep "")
    ]}
    complete --command "${wrapperName}" --require-parameter --no-files
  '';
  zshCompletions = pkgs.writeText "${wrapperName}-completions.zsh" ''
    #compdef ${wrapperName}

    (( $+function[_${sanitizedWrapperName}_commands] )) || _${sanitizedWrapperName}_commands () {
      local -a ${sanitizedWrapperName}_cmds
      ${sanitizedWrapperName}_cmds=(
        ${lib.pipe mission-control.scripts [
          (lib.mapAttrsToList (name: { description ? "", ... }: "'${name}:${toString description}'"))
          (lib.strings.concatStringsSep "\n")
        ]}
      )
      if (( CURRENT == 1 )); then
        _describe -t commands "${wrapperName} command" "''${${sanitizedWrapperName}_cmds}"
      fi
    }

    _arguments \
      {-h,--help}'[Print help text]' \
      '*::${wrapperName} commands:_${sanitizedWrapperName}_commands'
  '';
  wrapper =
    wrapCommands.overrideAttrs (oa: {
      meta.description = "Development scripts command";
      nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ pkgs.installShellFiles ];
      buildCommand = oa.buildCommand +
        (lib.strings.optionalString (withShellCompletions && commandNames != [ ]) ''
          installShellCompletion --cmd "${wrapperName}" \
            --bash "${bashCompletions}" \
            --fish "${fishCompletions}" \
            --zsh "${zshCompletions}"
        '');
    });
in
wrapper
