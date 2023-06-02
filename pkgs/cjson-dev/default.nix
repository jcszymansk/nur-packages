{ pkgs, cjson }:

let
  mylib = import ../../lib/default.nix { inherit pkgs; };
in
cjson.overrideAttrs (oldAttrs: {
  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=Off"
  ];

  setupHook = mylib.mkStaticSetupHook [ "cjson" ];
})
