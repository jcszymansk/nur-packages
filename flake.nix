{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    gradle2nix = {
      url = "github:tadfisher/gradle2nix/v2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, gradle2nix, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      pkgs = forAllSystems (system: import nixpkgs {
          inherit system;
          config.allowUnfree = true;
      });
      lib = nixpkgs.lib // (import ./lib nixpkgs.lib);
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = pkgs."${system}" // gradle2nix.builders."${system}";
        fromFlake = true;
      });
      devShells = forAllSystems (system: {
        default = pkgs."${system}".mkShell {};
      });
      modules = lib.loaddir (_: path: path) ./modules;
    };
}
