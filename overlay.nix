final: prev: {
  r0vm = final.callPackage ./pkgs/r0vm { };
  lib = (prev.lib or { }) // {
    buildRisc0Package = final.callPackage ./lib/buildRisc0Package.nix { };
  };
}
