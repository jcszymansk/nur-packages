{ lib, stdenv, pkgs }:

/* TODO: this adds include and lib folders to search paths, but since windows libraries are
   not distributed as dlls with mingw, but as .a files, it's still needed to add them to
   linker arguments. */
with pkgs;
cmake.overrideAttrs (oldAttrs: {
  pname = "cmake-cross";
  patches = oldAttrs.patches ++ [ ./007-cross-win.patch ];
})
