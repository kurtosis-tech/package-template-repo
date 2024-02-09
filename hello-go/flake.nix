# flake.nix

{
  description = "Hello, World! server in Go";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
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

        container = let
          arch = builtins.head
            (builtins.match "(.*)-.*" pkgs.stdenv.hostPlatform.system);
          go_arch =
            builtins.replaceStrings [ "x86_64" "aarch64" ] [ "amd64" "arm64" ]
            arch;
          os = "linux";
          tag = "${self.shortRev or "dirty"}";
          # if running from linux no cross-compilation is needed to palce the service in a container
          service = if pkgs.stdenv.isLinux then
            goPackage.overrideAttrs (old: old // { doCheck = false; })
          else
            goPackage.overrideAttrs (old:
              old // {
                GOOS = os;
                GOARCH = go_arch;
                doCheck = false;
              });
        in pkgs.dockerTools.buildImage {
          name = service.pname;
          tag = "latest";
          created = "now";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            paths = [ service ];
            pathsToLink = [ "/bin" ];
          };
          architecture = go_arch;
          config.Cmd = if pkgs.stdenv.isLinux then
            [ "${service}/bin/${service.pname}" ]
          else
            [ "${service}/bin/${os}_${go_arch}/${service.pname}" ];
        };

      in {
        packages.default = goPackage;
        packages.container = container;
      });
}
