{
  description = "Ferron 2.x";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "ferron";
        version = "2.5.5";
        src = ./.;
        
        buildFeatures = [ "config-yaml-legacy" ];
        
        cargoLock = {
          lockFile = ./Cargo.lock;
          outputHashes = {
            "async-compression-0.4.36" = "sha256-5rNEP5A7ahy+wv2U+lkGrG1ewVFhoFREsgeiQyXZzno=";
            "cache_control-0.2.0" = "sha256-Xw8JMo5bCgLfOsjsdyOxl956ggjWqywoQZA8Liz7bKE=";
            "dns-update-0.1.6" = "sha256-V5mUHWj6qAxRVCuQ6/XyvB992iJK22f5R+YNn1/BS+I=";
            "monoio-0.2.4" = "sha256-SnYzht1J3NedIjHK0MJVZFFWfjsZ42Dwnk2UJzFN8ZQ=";
          };
        };
        
        meta.license = pkgs.lib.licenses.mit;
      };
    };
}
