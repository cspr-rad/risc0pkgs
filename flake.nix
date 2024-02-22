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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    # Latest nixpkgs revision including the cached rustc version that risc0's rustc is based on.
    # For further details refer to the comments in pkgs/rustc0/default.nix
    nixpkgs-risc0-rustc.url = "github:NixOS/nixpkgs/34d8dbb93ddf91fb665b186d1c832b2d2f8e7ff7";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
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
      templates.default = {
        path = ./templates/default;
        description = "risc0 project template";
      };
    }
    // eachDefaultSystem (system:
      let
        pkgs-risc0-rustc = inputs.nixpkgs-risc0-rustc.legacyPackages.${system};
        rustc0 = pkgs-risc0-rustc.callPackage ./pkgs/rustc0 { };

        pkgs = nixpkgs.legacyPackages.${system};
        risc0pkgs = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs { });
        lib = pkgs.recurseIntoAttrs (pkgs.callPackage ./lib { pkgs = pkgs // risc0pkgs // { inherit rustc0; }; });
      in
      {
        inherit lib;
        packages = {
          inherit (risc0pkgs) r0vm;
          inherit rustc0;
        };

        formatter = pkgs.nixpkgs-fmt;

        checks.format = pkgs.runCommand "format-check" { buildInputs = [ pkgs.nixpkgs-fmt ]; } ''
          set -euo pipefail
          cd ${self}
          nixpkgs-fmt --check .
          touch $out
        '';

        herculesCI.ciSystems = [ "x86_64-linux" ];
      });
}
