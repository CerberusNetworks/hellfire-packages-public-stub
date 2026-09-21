{
  description = "Hellfire OS Pre-built Binary Packages (Stubs)";

  nixConfig = {
    extra-substituters = [ "https://cache.cerberusnetworks.io" ];
    extra-trusted-public-keys = [ "cloudrun-cache-1:ERwlaOUXZO2uKkQy20IO3CuyAvDCnsR8nn66+XZ8nHo=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      storePaths = import ./versions.nix;

      mkPackage = system: name:
        let
          path = storePaths.${system}.${name} or (throw "No pre-built ${name} for ${system}");
        in
        builtins.fetchClosure {
          fromStore = "https://cache.cerberusnetworks.io";
          fromPath = path;
        };
    in
    {
      packages = forAllSystems (system: {
        hellfire-client = mkPackage system "hellfire-client";
        hellfire-server = mkPackage system "hellfire-server";
        host-ctr        = mkPackage system "host-ctr";
        service-ctr     = mkPackage system "service-ctr";
      });

      overlays.default = final: prev: {
        hellfirePackages = {
          hellfire-client = mkPackage final.system "hellfire-client";
          hellfire-server = mkPackage final.system "hellfire-server";
          host-ctr        = mkPackage final.system "host-ctr";
          service-ctr     = mkPackage final.system "service-ctr";
        };
      };
    };
}