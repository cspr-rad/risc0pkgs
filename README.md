# risc0pkgs - Nixified [RISC Zero](https://www.risczero.com/) Packages

`risc0pkgs` contains risc0 related packages like `r0vm` and risc0's `rustc` fork packaged with Nix. Moreover, it provides a helper function: `buildRisc0Package`, which you can use to package your risc0 project. The following section describes how to set up a risc0 project from scratch.

## Getting Started

It's recommended to get started by initializing your project using the default template:

```sh
mkdir risc0-workspace
cd risc0-workspace

nix flake init -t github:cspr-rad/risc0pkgs

git init
git add -A

nix build .#risc0package
```

If you want to integrate `risc0` into your existing flake, see `./templates/default/flake.nix`.

## Development Shell

To get dropped into a development shell with all the required tooling, run:

```sh
nix develop
```
