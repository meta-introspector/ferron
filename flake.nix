{
  description = "Ferron 2.x for ZOS";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.runCommand "ferron-2.5.5" {} ''
        mkdir -p $out/bin
        cp ${./target/release/ferron} $out/bin/ferron
        chmod +x $out/bin/ferron
      '';
    };
}
