{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; {
  buildRisc0Package = callPackage ./buildRisc0Package.nix { };
})
