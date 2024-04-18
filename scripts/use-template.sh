#!/bin/bash

mkdir risc0-workspace
cd risc0-workspace

nix flake init -t ..#default

git init
git add -A

# Override the nixpkgs input of the template to use the current branch,
# since that is the branch of interest we want to test
nix flake lock --override-input risc0pkgs "github:cspr-rad/risc0pkgs/$GITHUB_REF"

nix build --accept-flake-config -L --no-link .#risc0package

