{ lib, stdenv, fetchurl, appimageTools, ... }:

let
  pname = "aider-desk";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/hotovo/aider-desk/releases/download/v${version}/Aider-Desk-${version}.AppImage";
    sha256 = "16pmzl9llr0zf7rvapk0n5kicgpwb50van9kmn4w3b887rq4hfrq";
  };

in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: with pkgs; [
    python3
  ];
}
