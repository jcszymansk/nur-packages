{ pkgs
, stdenv
, fetchFromGitHub
, fetchurl
, libarchive
, autoPatchelfHook
, makeWrapper
, wrapGAppsHook
, ...
}:

let
  oldpnpm = pkgs.nodePackages.pnpm.override rec {
    version = "7.33.1";
    name = "pnpm-${version}";
    src = fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-7.33.1.tgz";
      sha256 = "0nzdh0s9dkvf3lsqkhx00kvm1dl887bhdfq5hyiymlipd19mr19x";
    };
  };
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "rstewa";
    repo = "google-chat-electron";
    rev = "v${version}";
    sha256 = "sha256-omR0BuULSBvq8RxKfPmAljbt58uDtkfPJRdIBtQ7LzY=";
  };
  deps = stdenv.mkDerivation rec {
    inherit src version;

    pname = "google-chat-electron-deps";
    
    outputHash = "sha256-omR0BuULSBvq8RxKfPmAljbt58uDtkfPJRdIBtQ7LzY=";

    nativeBuildInputs = [ oldpnpm ];

    buildPhase = ''
      export HOME=/build
      pnpm config --location project set store-dir ./.store
      pnpm fetch
    '';

    dontInstall = true;
    dontFixup = true;
  };
in
stdenv.mkDerivation rec {
  inherit src version;

  pname = "google-chat-electron";

  nativeBuildInputs = [
    oldpnpm
  ];
  
  buildInputs = [
    deps
  ];
/*
  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    libarchive
    makeWrapper
    wrapGAppsHook
  ];

  buildInputs = with pkgs; [
    alsaLib
    at-spi2-atk
    cairo
    cups.lib
    dbus.lib
    glib
    gnome2.pango
    gtk3
    libxkbcommon
    mesa
    nspr
    nss_latest
    vivaldi-ffmpeg-codecs
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg_sys_opengl
  ];
  */

  meta = { broken = true; };
}
