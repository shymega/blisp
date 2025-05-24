{
  description = "Flake for the 'blisp' tool.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs:
    let
      inherit (inputs) self nixpkgs;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          blisp = pkgs.callPackage ./package.nix { inherit self; };
          default = self.packages.${system}.blisp;
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "blisp-dev";
            inputsFrom = with self.packages.${system}; [ blisp ];
          };
        }
      );
    };
}
