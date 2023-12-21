# risc0pkgs - Nixified [RISC Zero](https://www.risczero.com/) Packages

## Getting Started

It's recommended to get started by initializing your project using the default template:

```sh
mkdir risc0-workspace
cd risc0-workspace

nix flake init -t github:cspr-rad/risc0pkgs

git init
git add -A

nix build .#risc0prover
```

Note: Change the `system` to `aarch64-darwin` if you're on macOS.

If you want to integrate `risc0` into your existing flake, see `./templates/default/flake.nix`.

## Development Shell

To get dropped into a development shell with all the required tooling, run:

```sh
nix develop
```
