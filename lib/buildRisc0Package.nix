{ rustPlatform
, pkg-config
, cargo-risczero
, rustc
, lld
, writeShellApplication
, cargo
, openssl
, lib
, stdenv
, darwin
}:
attrs:

let
  rustup-mock = writeShellApplication {
    name = "rustup";
    runtimeInputs = [ ];
    text = ''
      # the buildscript uses rustup toolchain to check
      # whether the risc0 toolchain was installed
      if [[ "$1" = "toolchain" ]]
      then
        printf "risc0\n"
      elif [[ "$1" = "+risc0" ]]
      then
        printf "${rustc}/bin/rustc"
      fi
    '';
  };
  cargo-mock = writeShellApplication {
    name = "cargo";
    runtimeInputs = [ cargo ];
    text = ''
      # ignore +risc0
      if [[ "$1" = "+risc0" ]]
      then
        cargo "''${@:2}"
      else
        cargo "$@"
      fi
    '';
  };
  lld-mock = writeShellApplication {
    name = "rust-lld";
    runtimeInputs = [ lld ];
    text = ''
      ld.lld "$@"
    '';
  };
in

rustPlatform.buildRustPackage (lib.mergeAttrsConcatenateValues attrs {
  nativeBuildInputs = [
    pkg-config
    cargo-risczero
    rustc
    rustup-mock
    cargo-mock
    lld-mock
  ];
  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];
})
