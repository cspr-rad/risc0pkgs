{ makeRustPlatform
, pkg-config
, cargo-risczero
, rust-bin
, writeShellApplication
, openssl
, lib
, stdenv
, darwin
}:
extraBuildRustPackageAttrs@{ nativeBuildInputs ? [ ], preBuild ? "", buildInputs ? [ ], ... }:

let
  toolchain = rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
    extensions = [ "rust-src" ];
  });
  rustup-mock = writeShellApplication {
    name = "rustup";
    text = ''
      # the buildscript uses rustup toolchain to check
      # whether the risc0 toolchain was installed
      if [[ "$1" = "toolchain" ]]
      then
        printf "risc0\n"
      elif [[ "$1" = "+risc0" ]]
      then
        printf "${toolchain}/bin/rustc"
      fi
    '';
  };
  extraBuildRustPackageAttrsNoArgs = builtins.removeAttrs extraBuildRustPackageAttrs [ "buildInputs" "nativeBuildInputs" "preBuild" ];
in

(makeRustPlatform { rustc = toolchain; cargo = toolchain; }).buildRustPackage (lib.recursiveUpdate extraBuildRustPackageAttrsNoArgs {
  nativeBuildInputs = lib.unique ([
    pkg-config
    cargo-risczero
    rustup-mock
  ] ++ nativeBuildInputs);
  preBuild = ''
    export RISC0_RUST_SRC=${toolchain}/lib/rustlib/src/rust;
    ${preBuild}
  '';
  buildInputs = lib.unique ([
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ] ++ buildInputs);
  doCheck = false;
  auditable = false;
})
