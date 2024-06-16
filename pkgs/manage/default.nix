{ pkgs, lib, stdenv, substituteAll, ... }:

let
  substAttrs = pkg: bins: builtins.listToAttrs (map (name: {
    name = name;
    value = "${pkg}/bin/${name}";
  }) bins);
in
stdenv.mkDerivation {
  pname = "manage";
  version = "0.1.0";
  src = substituteAll ({
    src = ./manage.sh;
  } //
  substAttrs pkgs.coreutils [
    "mktemp" "basename" "dirname"
    "realpath" "sort" "cat" "rm"
    "head" "sha1sum" "cut"
  ] //
  substAttrs pkgs.findutils [
    "find"
  ] //
  substAttrs pkgs.age [
    "age"
  ]);

  dontUnpack = true;
  dontBuild = true;
  doInstallCheck = true;
  installCheckInputs = [ pkgs.shellcheck ];
  installCheckPhase = ''
    shellcheck $src
    if grep -q 'unsubsted @' $src; then
      echo "Unsubstituted variables found in $src" >&2
      grep -n 'unsubsted @' $src >&2
      exit 1
    fi
    '';
  installPhase = "install -D -m755 $src $out/bin/manage";

  meta = with lib; {
    description = "A simple script to manage age secrets in a directory tree";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ "jacekszymanski" ];
    mainProgram = "manage";
  };
}


