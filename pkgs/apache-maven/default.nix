{ pkgs, jdk ? pkgs.jdk17, ... }:

pkgs.maven.overrideAttrs (final: prev: rec {
  version = "3.9.5";
  src = builtins.fetchurl {
    url = "https://archive.apache.org/dist/maven/maven-3/${version}/binaries/${prev.pname}-${version}-bin.tar.gz";
    sha256 = "0z7ghjfi3w7r9ax56dzg714zq5g0cnbkkxj25qgfh7q40nqp5ljz";
  };
})
