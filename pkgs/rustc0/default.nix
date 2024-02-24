{ rustc
, fetchpatch
}:

# How to update the risc0's rustc derivation:
# 1. Find the latest nixpkgs revision that includes the cached rustc version that risc0's rust is based on:
# 1.1 Go to https://hydra.nixos.org/job/nixpkgs/trunk/rustc.x86_64-linux and grep for the version
# 1.2 Click the build number '#' for the respective version
# 1.3 Click the 'Inputs' tab and copy the nixpkgs revision, then update the nixpkgs-risc0-rustc input in the flake.nix, by replacing the revision hash

# 2. Update the version attribute below.

# Alternative:
# 2. Obtain the diff file that includes all the changes that risc0's fork introduces:
# 2.1 Go to https://github.com/rust-lang/rust/compare/master...risc0:rust:risc0
# 2.2 Change the base repository's branch/tag to the version that risc0's release is based on
# 2.3 Change the head repository's branch/tag to the risc0 release version
# 2.4 Download the diff by appending `.diff` to the URL e.g. https://github.com/rust-lang/rust/compare/1.70.0...risc0:rust:v2024-01-31.1.diff
# 2.5 Add the diff file next to this file (default.nix)
# 2.6 Modify the diff and remove the .github/workflows/ci.yml changes
rustc.overrideAttrs (final: prev: {
  version = "v2024-01-31.1";
  patches = (prev.patches or [ ]) ++ [
    (fetchpatch {
      url = "https://github.com/rust-lang/rust/compare/${prev.version}...risc0:rust:${final.version}.diff";
      hash = "sha256-kUCb4SXq7T0vNctMfLywjvEtlEdRRQhsy3RVP+/0Wmo=";
      excludes = [ ".github/workflows/ci.yml" ];
    })
  ];
})
