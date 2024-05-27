{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  inputs.openconnect-sso = {
    url = "github:jacekszymanski/openconnect-sso";
  };
  outputs = { self, nixpkgs, ... }@inputs:
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
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        inherit nixpkgs;
        inherit (inputs.openconnect-sso.packages."${system}") openconnect-sso;
        pkgs = pkgs."${system}";
      });
      devShells = forAllSystems (system: {
        default = pkgs."${system}".mkShell {};
      });
    };
}
