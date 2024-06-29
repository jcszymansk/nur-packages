{ pkgs, lib, stdenv, fetchgit
, sendmail ? "/run/wrappers/bin/sendmail" # default on NixOS
,  ...
}:

stdenv.mkDerivation rec {
  pname = "s-mailx";
  version = "14.9.25";
  src = fetchgit {
    url = "https://git.sdaoden.eu/scm/s-nail.git";
    rev = "refs/tags/v${version}";
    sha256 = "0z3w7a7cafrkrlrikccivzlzz1nw3i6i4z35j35kj5a2pg9h9ign";
  };

  configurePhase = ''
    make config CONFIG=NULLI VAL_PREFIX="" VAL_MTA=${sendmail}
    '';

  buildPhase = ''
    make build
    '';

  installPhase = ''
    make install DESTDIR=$out
    cd "$out"/bin
    ln -s s-nail mailx
    ln -s s-nail mail
    '';

}
