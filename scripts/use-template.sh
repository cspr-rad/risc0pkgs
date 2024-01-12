#!/bin/bash

mkdir risc0-workspace
cd risc0-workspace

nix flake init -t github:cspr-rad/risc0pkgs

git init
git add -A

nix build .#risc0package
