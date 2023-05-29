{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  mkStaticSetupHook = libs:
    let
      prependl = ln: concatStrings [ "-l" ln ];
      libstr = concatStringsSep " " (map prependl libs);
    in
      pkgs.writeText "setup-hook.sh" ''
        CFLAGS+=" -I''${out}/include "
        LDFLAGS+=" -L''${out}/lib ${libstr} "
        export CFLAGS LDFLAGS
      '';
}
