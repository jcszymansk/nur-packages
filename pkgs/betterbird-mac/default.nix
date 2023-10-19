{ pkgs
, fetchurl
, stdenv
, lib
, ...
}:

let
  data = with builtins; fromJSON (readFile ./betterbird.json);
in
stdenv.mkDerivation {
  inherit (data) version;
  pname = "betterbird";

  # TODO allow various versions etc.
  src = fetchurl {
    inherit (data) url sha256;
  };

  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [ undmg libplist jq ];

  dontConfigure = true;
  dontBuild = true;
  
  installPhase = ''
    mkdir -p $out/Applications
    cp Betterbird.app/Contents/Info.plist ./
    plistutil -f json < ./Info.plist | \
      jq '. += {"LSEnvironment": {"MOZ_ALLOW_DOWNGRADE": "1", "MOZ_LEGACY_PROFILES": "1"}}' | \
      plistutil -f binary > Betterbird.app/Contents/Info.plist
    rm -f ./Info.plist
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
