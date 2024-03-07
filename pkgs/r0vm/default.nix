{ rustPlatform
, stdenv
, fetchFromGitHub
, pkg-config
, perl
, openssl
, lib
, darwin
}:
rustPlatform.buildRustPackage rec {
  pname = "r0vm";
  version = "0.21.0-rc.1";
  src = fetchFromGitHub {
    owner = "risc0";
    repo = "risc0";
    rev = "v${version}";
    sha256 = "sha256-dT+lhlaVXapnQSe/TWCLyZ0vvkWoSPjFkNLcM7AYHDs=";
  };
  meta = with lib; {
    homepage = "https://github.com/risc0/risc0";
    description = "risc0's zkVM";
  };

  buildAndTestSubdir = "risc0/r0vm";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  # Workaround for https://github.com/NixOS/nixpkgs/issues/166205
  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_LDFLAGS = "-l${stdenv.cc.libcxx.cxxabi.libName}";
  };

  buildInputs = [
    openssl.dev
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  doCheck = false;

  cargoHash = "sha256-CpqhF+FBnhvKU2X8di+LR7/t7EajYgXzkBS3a+mfzTc=";

  postPatch =
    let
      # see https://github.com/risc0/risc0/blob/v0.20.0-rc.1/risc0/circuit/recursion/build.rs
      sha256Hash = "3504a2542626acb974dea1ae5542c90c032c4ef42f230977f40f245442a1ec23";
      recursionZkr = builtins.fetchurl {
        name = "recursion_zkr.zip";
        url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${sha256Hash}.zip";
        sha256 = "sha256:08zcl515890gyivhj8rgyi72q0qcr515bbm1vrsbkb164raa411m";
      };
    in
    ''
      cp ${recursionZkr} ./risc0/circuit/recursion/src/recursion_zkr.zip
    '';
}
