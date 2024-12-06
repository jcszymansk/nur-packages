{ buildNpmPackage
, fetchFromGitHub
, makeWrapper
, makeDesktopItem
, lib
, pkgs
, ...
}:

let
  ignoringVulns = x: x // { meta = (x.meta // { knownVulnerabilities = []; }); };
  electron = pkgs.electron_30.overrideAttrs ignoringVulns;
in
buildNpmPackage rec {
  pname = "simple-time-tracker";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jacekszymanski";
    repo = pname;
    rev = "master";
    hash = "sha256-txbrZ4a76fLCdK//fqbdF2sczJsgO5B088BirVFxe18=";
  };

  npmDepsHash = "sha256-NNdoILe3N7+qplytZMaQcfrk7vbzIAFgRS3yKZ0bJfg=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  desktopItem = makeDesktopItem {
    name = "simple-time-tracker";
    exec = "simple-time-tracker %U";
    icon = "simple-time-tracker";
    desktopName = "Simple Time Tracker";
    categories = [ "Office" ];
  };

  postInstall = ''
    mkdir -p $out/lib/node_modules/simple-time-tracker/app
    cp -ax src/* $out/lib/node_modules/simple-time-tracker/app/
    install -Dm0644 {${desktopItem},$out}/share/applications/simple-time-tracker.desktop

    pushd $out/lib/node_modules/simple-time-tracker/app/img/icons
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/simple-time-tracker.png
    done
    popd

    makeWrapper ${electron}/bin/electron $out/bin/simple-time-tracker \
      --add-flags $out/lib/node_modules/simple-time-tracker/app \
      --set npm_package_version ${version}
  '';

  distPhase = ":"; # disable useless $out/tarballs directory

  meta = with lib; {
    description = "Simple Time Tracker";
    maintainers = [ "jacekszymanski" ];
    platforms = platforms.unix;
    license = licenses.gpl3Plus;
  };

  passthru.skipCi = true;
}
