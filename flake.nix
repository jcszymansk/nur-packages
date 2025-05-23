{
  description = "My personal NUR repository";
  inputs = {
    # TODO add pinned 24.11 for electron_30, needed for simple-time-tracker
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    gradle2nix = {
      url = "github:milahu/gradle2nix/pull69-patch1";
      #url = "github:tadfisher/gradle2nix/v2";
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
