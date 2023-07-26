# mission-control

A `flake-parts` module for your Nix devshell scripts

https://zero-to-flakes.com/mission-control

> [!IMPORTANT]  
> We recommend that you use [just](https://just.systems/man/en/) over this module. For migration, see [this PR](https://github.com/srid/haskell-template/pull/111).

## Usage

To try out mission-control using the example template, start from one of the following ways:

- Run `nix flake init -t github:Platonic-Systems/mission-control` to create a template `flake.nix` file. Run `nix develop` on it.
- Or, clone this repo and checkout the [example](./example). On this directory, run `nix develop --override-input mission-control path:../.`[^override] (or simply `direnv allow` if you already use direnv) to drop into the Nix shell

[^override]: The `--override-input` option is to be used when running from this repository to make sure that we are using the local version of `mission-control`. If you are copying this `flake.nix` to your project (without also copying the outdated `flake.lock`), you can simply run `nix develop`.

The example configures the scripts in Nix as follows:

https://github.com/Platonic-Systems/mission-control/blob/a562943f45d9b8ae63dd62ec084202fdbdbeb83f/example/flake.nix#L16-L29

Which produces a banner in the devshell like below:

```
### ️🔨 Welcome to the Nix devshell ###

Available commands:

## Commands

  , hello    : Say Hello
  , ponysay  : Cowsay reimplemention for ponies

## Tools

  , fmt  : Format the Nix files

(Run ',' to display this menu again)
```

Once you are in the dev shell, you can run any of these scripts prefixed with the wrapper name `,`.  For example, `, fmt` to format the Nix files.

Note: The scripts will *always* be run from the project root directory[^flake-root] regardless of the current working directory. You can disable this behaviour by setting the `cdToProjectRoot` option to `false`.

[^flake-root]: "Project root directory" is determined by traversing the directory up until we find the unique file that exists only at the root. This unique file is `flake.nix` by default, which can be overridden using the [flake-root](https://github.com/srid/flake-root) module that this module mandatorily requires; i.e.; `flake-root.projectRootFile = "stack.yaml";`

## Examples

These repositories use `mission-control` to provide development shell workflow scripts:

- https://github.com/srid/haskell-template
- https://github.com/srid/ema-template
