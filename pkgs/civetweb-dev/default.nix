{ stdenv, civetweb, writeText }:

civetweb.overrideAttrs (oldAttrs: {
    pname = "civetweb-dev";
    cmakeFlags = [
      "-DBUILD_SHARED_LIBS=OFF"
      "-DCIVETWEB_ENABLE_CXX=OFF"
      "-DCIVETWEB_ENABLE_IPV6=OFF"
      "-DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF"
      "-DCIVETWEB_ENABLE_SSL=OFF"
      # The civetweb unit tests rely on downloading their fork of libcheck.
      "-DCIVETWEB_BUILD_TESTING=OFF"
    ];
    patches = [ ./mingw-cross.patch ];
    setupHook = writeText "setup-hook" ''
      CFLAGS+=" -I''${out}/include "
      LDFLAGS+=" -L''${out}/lib -lcivetweb "
      export CFLAGS LDFLAGS
    '';

})
