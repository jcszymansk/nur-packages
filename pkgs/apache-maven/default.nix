{ pkgs, ... }:

pkgs.maven.overrideAttrs (final: prev: rec {
  version = "3.9.2";
  src = builtins.fetchurl {
    url = "https://dlcdn.apache.org/maven/maven-3/${version}/binaries/${prev.pname}-${version}-bin.tar.gz";
    sha256 = "0z8i6k07n5l3xgcczib6lp5qwkfklswlqckcq2ar25vd1hig77l0";
  };
})
