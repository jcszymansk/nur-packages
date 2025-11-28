{ stdenv
, vscode
, fetchurl
, libsoup_3
, webkitgtk_4_1
, ... } @ args:

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
  (vscode.override {
    isInsiders = true;
  }).overrideAttrs (prev: {
    inherit src version;
    pname = "vscode-insiders";
    buildInputs = prev.buildInputs ++ [ libsoup_3 webkitgtk_4_1 ];
    meta = prev.meta // { mainProgram = "code-insiders"; };
  })
