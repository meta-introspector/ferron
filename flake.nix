{
  description = "Ferron web server for ZOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "ferron";
        version = "1.3.9";

        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "cache_control-0.2.0" = "sha256-Xw8JMo5bCgLfOsjsdyOxl956ggjWqywoQZA8Liz7bKE=";
          };
        };

        meta = {
          description = "Fast, memory-safe web server";
          license = pkgs.lib.licenses.mit;
        };
      };
    };
}
