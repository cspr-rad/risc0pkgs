# risc0pkgs - Nixified [RISC Zero](https://www.risczero.com/) Packages

## Getting Started

Start with adding `risc0pkgs` as an input in your top-level `flake.nix` and define an initial package output (no existing sources/`src` required yet) as well as a dev-shell output:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    risc0pkgs.url = "github:cspr-rad/risc0pkgs";
    risc0pkgs.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, risc0pkgs ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.risc0package = risc0pkgs.lib.${system}.buildRisc0Package {
          pname = "risc0package";
          version = "0.0.1";
          src = ./.; 
          doCheck = false;
          cargoSha256 = pkgs.lib.fakeSha256;
        };

      devShells.${system}.default =  pkgs.mkShell {
        RISC0_DEV_MODE = 1;
        inputsFrom = [ self.packages.${system}.risc0package ];
        nativeBuildInputs = [
          inputs.risc0pkgs.packages.${system}.r0vm
        ];
      };
    };
}
```

Enter the dev-shell by executing `nix develop` in your terminal and follow the steps explained in the RISC zero quick start guide: [2. Create a New Project](https://dev.risczero.com/api/zkvm/quickstart#2-create-a-new-project).

Inside the dev-shell, you can execute `cargo run` just like explained in the quick start guide.

Once you've created a risc0 project as explained in [2. Create a New Project](https://dev.risczero.com/api/zkvm/quickstart#2-create-a-new-project) you will have to stage the newly created files (as Nix will ignore files that are not captured by version control) and change the source directory: Assuming you've created a risc0 project called `my_project` in the root directory of your repository, change
```nix
packages.${system}.risc0package = risc0pkgs.lib.${system}.buildRisc0Package {
    pname = "risc0package";
    version = "0.0.1";
    src = ./.; 
    doCheck = false;
    cargoSha256 = pkgs.lib.fakeSha256;
  };
```
to 
```nix
packages.${system}.risc0package = risc0pkgs.lib.${system}.buildRisc0Package {
    pname = "risc0package";
    version = "0.0.1";
    src = ./my_project; 
    doCheck = false;
    cargoSha256 = pkgs.lib.fakeSha256;
  };
```

Running `nix build .#risc0package` will error the first time you run it because we still have to change the `cargoSha256`. Nix will tell us after this first run what the expected hash should be. Copy the expected hash and paste it here `cargoSha256 = "<hash>";`.
