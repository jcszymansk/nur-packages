{ pkgs
, stdenv
, fetchurl
, makeDesktopItem
, ... }:

stdenv.mkDerivation rec {
  pname = "sqldeveloper";
  version = "24.3.1.347.1826";

  src = fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-${version}-no-jre.zip";
    sha256 = "sha256-M5DvWJcvHyVQd8SeZrFxuGZHc7sW43Vwp8oWrMWvuMs=";
  };

  nativeBuildInputs = with pkgs; [
    unzip
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;

  desktopItem = makeDesktopItem {
    desktopName = "SQL Developer";
    name = "sqldeveloper";
    exec = "sqldeveoper.sh";
    icon = "sqldeveloper";
    categories = [ "Development" "Database" ];
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out/
    mkdir -p $out/share/applications
    install -Dm0644 {${desktopItem},$out}/share/applications/sqldeveloper.desktop
    mkdir -p $out/share/icons/hicolor/32x32/apps
    cp  icon.png $out/share/icons/hicolor/32x32/apps/sqldeveloper.png
    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/bin
    makeWrapper $out/sqldeveloper.sh $out/bin/sqldeveloper \
      --prefix PATH : ${pkgs.jdk17}/bin \
      --set JAVA_HOME ${pkgs.jdk17}
  '';

  meta = with pkgs.lib; {
    description = "Oracle SQL Developer is a free integrated development environment that simplifies the development and management of Oracle Database";
    homepage = "https://www.oracle.com/database/technologies/appdev/sql-developer.html";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "sqldeveloper";
  };

}
