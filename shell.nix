{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name="web-development";
  buildInputs = with pkgs; [
    nodePackages.npm
    nodejs
    yarn
    hugo
    micro
  ];

  shellHook=''
    echo "Shan6a7 Shalafan6a7"
  '';
}
