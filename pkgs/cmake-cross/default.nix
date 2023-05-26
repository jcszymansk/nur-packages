{ lib, stdenv, pkgs }:

with pkgs;
cmake.overrideAttrs (oldAttrs: {
  pname = "cmake-cross";
  patches = oldAttrs.patches ++ [ ./007-cross-win.patch ];
})
