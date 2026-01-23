{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "ralphy-help-check";
  buildInputs = [ pkgs.cacert ];
  src = pkgs.fetchurl {
    url = "https://registry.npmjs.org/ralphy-cli/-/ralphy-cli-4.5.3.tgz";
    sha256 = "/hwKwlsIOplkk+4HltPHynwJo3/kY5l6UGATTAAKA5o=";
  };
  unpackPhase = ''
    mkdir -p $TMP
    tar -xzf "$src" -C $TMP
    mv $TMP/package $TMP/ralphy-pkg
  '';
  checkPhase = ''
    echo "Running packaged ralphy.sh --help"
    $TMP/ralphy-pkg/ralphy.sh --help | grep -i "usage\|ralphy"
  '';
  installPhase = ''
    mkdir -p $out
    echo done > $out/result
  '';
}
