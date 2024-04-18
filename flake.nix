{
  description = "A collection of risc0 related packages";

  nixConfig = {
    extra-substituters = [
      "https://risc0pkgs.cachix.org"
    ];
    extra-trusted-public-keys = [
      "risc0pkgs.cachix.org-1:EY5UazX0/Q7hGCm6xQSgKX6UkpzyOf07pxjfhhRK7kE="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, rust-overlay, ... }:
    let
      eachSystem = systems: f:
        let
          # Merge together the outputs for all systems.
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key: attrs //
                {
                  ${key} = (attrs.${key} or { })
                    // { ${system} = ret.${key}; };
                }
              ;
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      herculesCI.ciSystems = [ "x86_64-linux" "aarch64-linux" ];
      templates.default = {
        path = ./templates/default;
        description = "risc0 project template";
      };
    }
    // eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend (import rust-overlay);
        risc0pkgs = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs { });
        lib = pkgs.recurseIntoAttrs (pkgs.callPackage ./lib { pkgs = pkgs; });
      in
      {
        inherit lib;
        packages = {
          inherit (risc0pkgs) r0vm;
        };

        formatter = pkgs.nixpkgs-fmt;

        checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
          set -euo pipefail
          cd ${self}
          nixpkgs-fmt --check .
          touch $out
        '';
      });
}
