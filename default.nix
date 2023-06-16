# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs;
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  pam-impermanence = pkgs.callPackage ./pkgs/pam-impermanence { pam = pkgs.pam; };
  # this builds all but installs only altered pam_unix
  # TODO: build only what's neded
  pam-impermalite = callPackage ./pkgs/pam-impermalite { inherit pam; };
  openconnect-sso = callPackage ./pkgs/openconnect-sso { inherit pkgs; };

  apache-maven = callPackage ./pkgs/apache-maven { inherit pkgs; };

}
