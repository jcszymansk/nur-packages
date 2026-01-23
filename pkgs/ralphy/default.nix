{ lib, stdenv, fetchFromGitHub, fetchurl, nodejs, yarn, bun, makeWrapper, cacert, fetchzip, pkgs, fromFlake ? false, ... }:

let
  npmTarball = fetchurl {
    url = "https://registry.npmjs.org/ralphy-cli/-/ralphy-cli-4.5.3.tgz";
    sha256 = "/hwKwlsIOplkk+4HltPHynwJo3/kY5l6UGATTAAKA5o=";
  };
  ralphyRepo = fetchFromGitHub {
    owner = "michaelshimeles";
    repo = "ralphy";
    rev = "6dcfaff";
    sha256 = "s6grgS5AIxcZEG4WB284gIuetC3kISGCuU7xGmlvL+M=";
  };
in
stdenv.mkDerivation rec {
  pname = "ralphy";
  version = "4.5.3";

  src = npmTarball;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [];

  unpackPhase = ''
    runHook preUnpack
    mkdir -p $TMP
    tar -xzf "$src" -C $TMP
    # npm tarball contains package/ directory
    mv $TMP/package $TMP/ralphy-pkg
    runHook postUnpack
  '';
  checkPhase = ''
    runHook preCheck
    echo "Checking ralphy help output"
    if [ -f "$TMP/ralphy-pkg/ralphy.sh" ]; then
      "$TMP/ralphy-pkg/ralphy.sh" --help 2>&1 | grep -i "usage\|ralphy"
    else
      ${ralphyRepo}/ralphy.sh --help 2>&1 | grep -i "usage\|ralphy"
    fi
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/ralphy

    # Install the upstream shell script as the entrypoint to avoid invoking Bun
    # directly from the prebuilt binary which executes Bun in this environment.
    # try to use the script from the npm package; otherwise use the upstream repo copy
    if [ -f "$TMP/ralphy-pkg/ralphy.sh" ]; then
      install -Dm0755 "$TMP/ralphy-pkg/ralphy.sh" $out/bin/ralphy
    else
      install -Dm0755 ${ralphyRepo}/ralphy.sh $out/bin/ralphy
    fi
    # also install package files for reference
    cp -r "$TMP/ralphy-pkg"/* $out/lib/ralphy/ || true

    runHook postInstall
  '';

  passthru = {
    skipCi = true; # lightweight package, no CI required for local builds
  };

  meta = with lib; {
    description = "Ralphy CLI (prebuilt binary from npm)";
    homepage = "https://github.com/michaelshimeles/ralphy";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
