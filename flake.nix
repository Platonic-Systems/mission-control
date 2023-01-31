{
  description = "A `flake-parts` module for your Nix devshell scripts";
  outputs = { self, ... }: {
    flakeModule = ./nix/flake-module.nix;
    templates.default = {
      description = "Example flake using mission-control to provide scripts";
      path = builtins.path { path = ./example; filter = path: type: baseNameOf path == "flake.nix"; };
    };
  };
}
