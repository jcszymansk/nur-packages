{ pkgs, lib, stdenv, fetchgit
, sendmail ? "/run/wrappers/bin/sendmail" # default on NixOS
,  ...
}:

stdenv.mkDerivation rec {
  pname = "s-mailx";
  version = "14.9.24";
  src = fetchgit {
    url = "https://git.sdaoden.eu/scm/s-nail.git";
    branchName = "stable/stable";
    sha256 = "sha256-Za7EV5EGMN0a2zUmn67sztkaRZxgiH1uCgtuE0lDTEw=";
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
