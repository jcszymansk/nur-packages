# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} 
, fromFlake ? false
, ...
}@args:

let
  lib = pkgs.lib // (import ./lib pkgs.lib);
  readyPkgs = lib.loaddir (_: path: import path pkgs) ./pkgs;
in
readyPkgs //
{
  # The `lib`, `modules`, and `overlay` names are special
  inherit lib;
  modules = lib.loaddir (_: path: path) ./modules; # modules
  overlays = import ./overlays; # nixpkgs overlays

}
