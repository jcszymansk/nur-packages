{ nixpkgs
, stdenv
, pkgs
, lib
, fetchurl
, callPackage
, commandLineArgs ? ""
, useVSCodeRipgrep ? stdenv.isDarwin
, ... }:

/*
 * cannot just override because the fhs function captures the original
 * derivation, not the overriden one, so won't get FHS version of the
 * insiders' build.
 */
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  plat = {
    x86_64-linux = "linux-x64";
    x86_64-darwin = "darwin";
    aarch64-linux = "linux-arm64";
    aarch64-darwin = "darwin-arm64";
    armv7l-linux = "linux-armhf";
  }.${system} or throwSystem;

  data = with builtins; fromJSON (readFile (./. + "/latest-${plat}.json"));
  version = data.productVersion;
  src = fetchurl {
    url = data.url;
    sha256 = data.sha256hash;
  };
in
  callPackage "${nixpkgs}/pkgs/applications/editors/vscode/generic.nix" {
    inherit version src;
    pname = "vscode-insiders";

    executableName = "code-insiders";
    longName = "Visual Studio Code - Insiders";
    shortName = "Code - Insiders";
    inherit commandLineArgs useVSCodeRipgrep;

    # We don't test vscode on CI, instead we test vscodium
    tests = {};

    sourceRoot = "";

    updateScript = ./update-vscode.sh;

    # Editing the `code` binary within the app bundle causes the bundle's signature
    # to be invalidated, which prevents launching starting with macOS Ventura, because VS Code is notarized.
    # See https://eclecticlight.co/2022/06/17/app-security-changes-coming-in-ventura/ for more information.
    dontFixup = stdenv.isDarwin;

    meta = with lib; {
      description = ''
        Open source source code editor developed by Microsoft for Windows,
        Linux and macOS
      '';
      mainProgram = "code";
      longDescription = ''
        Open source source code editor developed by Microsoft for Windows,
        Linux and macOS. It includes support for debugging, embedded Git
        control, syntax highlighting, intelligent code completion, snippets,
        and code refactoring. It is also customizable, so users can change the
        editor's theme, keyboard shortcuts, and preferences
      '';
      homepage = "https://code.visualstudio.com/";
      downloadPage = "https://code.visualstudio.com/Updates";
      license = licenses.unfree;
      maintainers = [ "jacekszymanski" ];
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" "armv7l-linux" ];
    };
  }