{ lib, stdenv, fetchurl, appimageTools, makeWrapper, coreutils, ... }:

let
  pname = "aider-desk";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/hotovo/aider-desk/releases/download/v${version}/Aider-Desk-${version}.AppImage";
    sha256 = "16pmzl9llr0zf7rvapk0n5kicgpwb50van9kmn4w3b887rq4hfrq";
  };

  aider-desk-raw = appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: with pkgs; [
      python3
    ];

    nativeBuildInputs = [ makeWrapper ];

    postInstall = ''
      wrapProgram $out/bin/${pname} --set AIDER_DESK_NO_AUTO_UPDATE true
    '';
  };
in
stdenv.mkDerivation {
  pname = "aider-desk-wrapper";
  inherit version;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontCheck = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    ln -s ${aider-desk-raw}/bin/${pname} $out/bin/${pname}
    wrapProgram $out/bin/${pname} \
      --set AIDER_DESK_NO_AUTO_UPDATE true \
      --run "${coreutils}/bin/chmod -R u+w \''${XDG_CONFIG_HOME:-\$HOME/.config}/${pname}" \
  '';
}
