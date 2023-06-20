{ pkgs, fetchurl, ... }:

let
  data = with builtins; fromJSON (readFile ./latest.json);
  version = data.productVersion;
  src = fetchurl {
    url = data.url;
    sha256 = data.sha256hash;
  };
in
(pkgs.vscode.overrideAttrs (prev: {
  inherit src version;
  pname = "vscode-insiders";
})).override { isInsiders = true; }
