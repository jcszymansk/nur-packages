{ stdenv, lib, fetchurl, pkgs }:

let
 cc = stdenv.cc;
 mylib = import ../../lib { inherit pkgs; };
in
stdenv.mkDerivation rec {
  pname = "sqlite-dev";
  version = "3.42.0";

  src = with lib; let
    relYear = "2023";
    vstr = concatStrings (splitVersion version);
    finalvstr = substring 0 7 (vstr + "0000000");
  in fetchurl {
    url = "https://www.sqlite.org/${relYear}/sqlite-autoconf-${finalvstr}.tar.gz";
    sha256 = "sha256-erz9FhxuJ0LKXGwIldH4U8lA8gMwSgtJ2k4eyl0IjKY=";
  };

  buildInputs = [ cc ];

  makeFlags = [
    "CC_FOR_BUILD=${cc}"
    "CC=${cc}"
    "CFLAGS=-DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_FTS4=1 -DSQLITE_ENABLE_FTS5=1 -DSQLITE_ENABLE_JSON1=1 -DSQLITE_ENABLE_RTREE=1 -DSQLITE_ENABLE_SESSION=1 -DSQLITE_ENABLE_UNLOCK_NOTIFY=1 -DSQLITE_HAVE_ISNAN -DSQLITE_SOUNDEX -DSQLITE_THREADSAFE=1 -DSQLITE_USE_URI=1 -O2 -DNDEBUG"
    "LDFLAGS=-static"
  ];

  configureFlags = [
    "--disable-shared"
    "--enable-static"
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  # remove binary & man, leave only .a & .h
  preFixup = ''
    rm -r $out/bin $out/share
  '';

  setupHook = mylib.mkStaticSetupHook [ "sqlite3" ];

  meta = {
    description = "SQLite is a software library that provides a relational database management system.";
    homepage = https://www.sqlite.org/;
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
}
