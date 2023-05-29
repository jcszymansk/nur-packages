{ pkgs
, stdenv
, fetchFromGitHub
, cmake
, ... }:

let
  mylib = import ../../lib { inherit pkgs; };
in
stdenv.mkDerivation rec {
  pname = "l8w8jwt-dev";
  version = "2.1.7";
  src = fetchFromGitHub {
    owner = "GlitchedPolygons";
    repo = "l8w8jwt";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "sha256-HpTHdCEyk3Jk2/zPCCASgp7jo/RiN5AXkxK/Ma9Srig=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=OFF"
    "-DUSE_SHARED_MBEDTLS_LIBRARY=OFF"
    "-DCMAKE_BUILD_TYPE=Release"

    # For mbedtls so it doesn't bark; should make it use the nixpkgs one anyway.
    "-DGEN_FILES=OFF"
  ];

  # I have no idea why install doesn't install this but does mbedtls.
  preInstall = ''
    mkdir -p $out/include/l8w8jwt
    cp -r ../include/l8w8jwt/* $out/include/l8w8jwt
    mkdir -p $out/lib
    cp libl8w8jwt.a $out/lib
  '';

  setupHook = mylib.mkStaticSetupHook [ "l8w8jwt" "mbedtls" ];
}
