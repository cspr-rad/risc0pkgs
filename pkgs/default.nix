{ pkgs, lib }:

lib.makeScope pkgs.newScope (self: with self; {
  r0vm = callPackage ./r0vm { };
})
