{
  description = "A very basic flake";

  outputs = { self, nixpkgs }:
  let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    devShell.x86_64-linux =
      pkgs.mkShell {
        buildInputs = [
          pkgs.nodePackages.npm
          pkgs.nodejs
          pkgs.yarn
          pkgs.hugo
          pkgs.micro
        ];
      
      shellHook=''
        fish
      '';
      };
  };
}
