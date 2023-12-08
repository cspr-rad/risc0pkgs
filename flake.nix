{
  description = "A collection of risc0 related packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      risc0pkgs = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs { });
      lib = pkgs.recurseIntoAttrs (pkgs.callPackage ./lib { pkgs = pkgs // risc0pkgs; });
    in
    {
      lib.${system} = lib;
      packages.${system} = { inherit (risc0pkgs) r0vm rustc0; };
      formatter.${system} = pkgs.nixpkgs-fmt;

      checks.${system}.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
        set -euo pipefail
        cd ${self}
        nixpkgs-fmt --check .
        touch $out
      '';
    };
}
