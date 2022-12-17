# mission-control

A `flake-parts` module for your Nix devshell scripts

**NOTE**: This is a work in progress. It is not yet ready for use.

## Example

See the [example](./example) directory for a working example. Run `nix develop` (or `direnv allow`) to drop into the Nix shell, which will display the mission control banner as shown below:

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
