{ pkgs
, fetchurl
, stdenv
, lib
, ...
}:

stdenv.mkDerivation {
  pname = "betterbird";
  version = "102.14.0-bb39";

  # TODO allow various versions etc.
  src = fetchurl {
    url = "https://www.betterbird.eu/downloads/MacDiskImage/betterbird-102.14.0-bb39.en-US.mac.dmg";
    sha256 = "0rxaah7d3xsb094sphr17b4d5bnj599n9i6yw58z9572kn23yi8j";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.undmg ];

  dontConfigure = true;
  dontBuild = true;
  
  installPhase = ''
    mkdir -p $out/Applications
    cp -r Betterbird.app $out/Applications
  '';

  meta = {
    description = "A patched Thunderbird";
    homepage = "https://www.betterbird.eu/";
    platforms = lib.platforms.darwin;
    maintainers = [ "jacekszymanski" ];
    broken = !stdenv.isDarwin;
  };

}
