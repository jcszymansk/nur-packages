{ pkgs, ... }:

pkgs.maven.overrideAttrs (final: prev: rec {
  version = "3.9.3";
  src = builtins.fetchurl {
    url = "https://archive.apache.org/dist/maven/maven-3/${version}/binaries/${prev.pname}-${version}-bin.tar.gz";
    sha256 = "1wd4km8n4kxvzd73azax4nw85xnf5rjzqzy503cn8frgqk03mqg1";
  };
})
