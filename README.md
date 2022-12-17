# mission-control

A `flake-parts` module for your Nix devshell scripts

## Example

See the [example](./example) directory for a working example.

Run `nix develop --override-input mission-control path:../.`[^override] (or simply `direnv allow` if you already use direnv) to drop into the Nix shell, which will display the mission control banner as shown below:

[^override]: The `--override-input` option is to be used when running from this repository to make sure that we are using the local version of `mission-control`. If you are copying this `flake.nix` to your project (without also copying the outdated `flake.lock`), you can simply run `nix develop`.

```
### ️🔨 Welcome to the Nix devshell ###

Available commands:

## Commands

  , hello  : Say Hello

## Tools

  , fmt  : Format the Nix files

(Run ',' to display this menu again)
```

Now run, for example, `, fmt` to run the corresponding script.

The scripts will be run *always* from the project root directory[^flake-root] regardless of the current working directory.

[^flake-root]: "Project root directory" is determined by traversing the directory up until we find the unique file that exists only at the root. This unique file is `flake.nix` by default, which can be overridden using the [flake-root](https://github.com/srid/flake-root) module; i.e.; `flake-root.projectRootFile = "stack.yaml";`
