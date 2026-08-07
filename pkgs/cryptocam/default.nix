{ lib
, rustPlatform
, fetchFromGitLab
, pkg-config
, ffmpeg
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "cryptocam";
  version = "0.1.3";

  src = fetchFromGitLab {
    owner = "cryptocam";
    repo = "cryptocam-companion-cli";
    rev = "30560231c79e704a5f22c7da270d6a477b70e05a";
    hash = "sha256-uhzhCsq9u2Qv802kiWtFTYvOUsNkxBhqoHoCjf/9ujQ=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "libcryptocam-0.1.6" = "sha256-ak5cjE1mSTrleV2OzFgbs7dqA9SZShQtC+qhrXequsE=";
      "ac-ffmpeg-0.19.0" = "sha256-pcXxYR/TV0a3uwUjAOlN41/53Bn3PLy9FDOoaUmdPUs=";
    };
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ffmpeg ];
  strictDeps = true;

  meta = with lib; {
    description = "CLI tool to decrypt Cryptocam videos and manage keys";
    homepage = "https://gitlab.com/cryptocam/cryptocam-companion-cli";
    license = licenses.gpl3Plus;
    maintainers = [ "jacekszymanski" ];
    platforms = platforms.unix;
    mainProgram = "cryptocam";
  };
}
