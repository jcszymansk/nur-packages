{ pkgs, fetchurl, ... }:

let
  sox = pkgs.callPackage "${pkgs.path}/pkgs/by-name/so/sox/package.nix" {
    enableLame = true;
  };
in
sox.overrideAttrs (_: {
  version = "14.4.2";

  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2.tar.bz2";
    hash = "sha256-gaaVbUMw51tYJzFuRK44Hm8eiSgAPGqkWJbakEHqFJw=";
  };

  postPatch = ''
    substituteInPlace src/sox_sample_test.h \
      --replace-fail '#include "sox.h"' $'#include <math.h>\n#include "sox.h"'
  '';

  patches = [ ];
})
