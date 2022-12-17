# mission-control

A `flake-parts` module for your Nix devshell scripts

## Usage

To try out mission-control, start from one of the following ways:

- Run `nix flake init -t github:Platonic-Systems/mission-control` to create a template `flake.nix` file. Run `nix develop` on it.
- Clone this repo and checkout the [example](./example). On this directory, run `nix develop --override-input mission-control path:../.`[^override] (or simply `direnv allow` if you already use direnv) to drop into the Nix shell

[^override]: The `--override-input` option is to be used when running from this repository to make sure that we are using the local version of `mission-control`. If you are copying this `flake.nix` to your project (without also copying the outdated `flake.lock`), you can simply run `nix develop`.

Once you are in the Nix develop shell, you'll see a banner like below:

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

Now run, for example, `, fmt` to run the corresponding script.

The scripts will be run *always* from the project root directory[^flake-root] regardless of the current working directory.

[^flake-root]: "Project root directory" is determined by traversing the directory up until we find the unique file that exists only at the root. This unique file is `flake.nix` by default, which can be overridden using the [flake-root](https://github.com/srid/flake-root) module; i.e.; `flake-root.projectRootFile = "stack.yaml";`

## Examples

These repositories use `mission-control` to provide development shell workflow scripts:

- https://github.com/srid/haskell-template
