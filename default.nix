# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };
  cmake-cross = pkgs.callPackage ./pkgs/cmake-cross { };

  # -dev packages are static libs and headers
  l8w8jwt-dev = pkgs.callPackage ./pkgs/l8w8jwt-dev { };
  civetweb-dev = pkgs.callPackage ./pkgs/civetweb-dev { };
  sqlite-dev = pkgs.callPackage ./pkgs/sqlite-dev { };




}
