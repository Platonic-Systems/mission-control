{
  description = "A `flake-parts` module for your Nix devshell scripts";
  outputs = { ... }: {
    flakeModule = ./nix/flake-module.nix;
    templates.default = {
      description = "Example flake using mission-control to provide scripts";
      path = builtins.path { path = ./example; filter = path: type: baseNameOf path == "flake.nix"; };
    };

    # Config for https://github.com/srid/nixci
    # To run this, `nix run github:srid/nixci`
    nixci.default = let overrideInputs = { "mission-control" = ./.; }; in {
      example = {
        inherit overrideInputs;
        dir = "./example";
      };
      dev = {
        dir = "./dev";
      };
      doc.dir = "./doc";
    };
  };
}
