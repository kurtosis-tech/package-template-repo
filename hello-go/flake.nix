# flake.nix

{
  description = "Hello, World! server in Go";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pname = "hello";
        src = ./.;

        goPackage = pkgs.buildGoModule {
          inherit pname src;
          version = "0.0.1";
          vendorHash = null;
          nativeBuildInputs = [ pkgs.stdenv ];
          CGO_ENABLED = 0;
        };

        containerImage = let
          content = goPackage.overrideAttrs (old:
            old // {
              GOOS = "linux";
              GOARCH = "arm64";
              doCheck = false;
            });
        in pkgs.dockerTools.buildImage {
          name = "hello-world-server";
          tag = "latest";
          config.Cmd = [ "${content}/bin/linux_arm64/${pname}" ];
        };

      in {
        defaultPackage = goPackage;
        packages.containerImage = containerImage;
      });
}
