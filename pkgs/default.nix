{ pkgs, lib, pkgs-risc0-rustc }:

lib.makeScope pkgs.newScope (self: with self; {
  r0vm = callPackage ./r0vm { };
  rustc0 = pkgs-risc0-rustc.callPackage ./rustc0 { };
})
