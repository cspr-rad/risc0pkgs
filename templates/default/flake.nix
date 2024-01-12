{
  description = "risc0 project template";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    risc0pkgs = {
      url = "github:cspr-rad/risc0pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, risc0pkgs }:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          risc0package =
            risc0pkgs.lib.${system}.buildRisc0Package {
              pname = "risc0package";
              version = "0.0.1";
              src = ./.;
              doCheck = false;
              cargoSha256 = "sha256-oY52S/Yljkn9lfH8oA8+XkCwAwOaOBzIT5uLCMZZYxI=";
              nativeBuildInputs = [ pkgs.makeWrapper ];
              postInstall = ''
                wrapProgram $out/bin/host \
                  --set PATH ${pkgs.lib.makeBinPath [ risc0pkgs.packages.${system}.r0vm ]}
              '';
            };
        });

      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            RISC0_DEV_MODE = 1;
            inputsFrom = [ self.packages.${system}.risc0package ];
            nativeBuildInputs = [ risc0pkgs.packages.${system}.r0vm ];
          };
        });
    };
}
