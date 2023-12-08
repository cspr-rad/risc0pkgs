{ rustPlatform
, fetchFromGitHub
, pkg-config
, perl
, openssl
, lib
}:
rustPlatform.buildRustPackage rec {
  pname = "r0vm";
  version = "0.19.1";
  src = fetchFromGitHub {
    owner = "risc0";
    repo = "risc0";
    rev = "v${version}";
    sha256 = "sha256-TR6Yfxa4cA53eAPPs5MP/4Kh1z8/ZpsdWugp2bdPHqM=";
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

  buildInputs = [ openssl.dev ];

  doCheck = false;

  cargoPatches = [
    ./add-Cargo.lock.patch
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "ark-secret-scalar-0.0.2" = "sha256-Nbf77KSsAjDKiFIP5kgzl23fRB+68x1EirNuZlS7jeM=";
      "common-0.1.0" = "sha256-3OKBPpk0exdlV0N9rJRVIncSrkwdI8bkYL2QNsJl+sY=";
      "fflonk-0.1.0" = "sha256-+BvZ03AhYNP0D8Wq9EMsP+lSgPA6BBlnWkoxTffVLwo=";
      "frame-support-4.0.0-dev" = "sha256-bHGR9Hl0JUxYeZdha9G7ISue4M2LMt+dGyw65CX99TM=";
    };
  };
  postPatch =
    let
      rev = "505295b963c97db2afffe58f4b0cb4721e396b90";
      recursionZkr = builtins.fetchurl {
        name = "recursion_zkr.zip";
        url = "https://github.com/risc0/risc0/raw/${rev}/risc0/circuit/recursion/src/recursion_zkr.zip";
        sha256 = "sha256:0rvmgqgkhas39yg1jll022l29s05b5b7f17pyvzi9nbwv2k667d0";
      };
    in
    ''
      cp ${recursionZkr} ./risc0/circuit/recursion/src/recursion_zkr.zip
    '';
}
