{
  description = "volctl - Per-application volume control for Linux desktops";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        volctl = pkgs.callPackage ./default.nix { };
      in
      {
        packages = {
          default = volctl;
          volctl = volctl;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.setuptools
          ];
        };

        apps.default = {
          type = "app";
          program = "${volctl}/bin/volctl";
        };
      }
    );
}
