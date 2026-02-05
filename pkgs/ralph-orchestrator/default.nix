{ lib
, rustPlatform
, fetchFromGitHub
, system ? null
, fromFlake ? false
, ...
}:

rustPlatform.buildRustPackage rec {
  pname = "ralph-orchestrator";
  version = "2.4.4";

  src = fetchFromGitHub {
    owner = "mikeyobrien";
    repo = "ralph-orchestrator";
    rev = "v${version}";
    hash = "sha256-JsaI6Z8ylmI0KmtmuBkRZnqK7McEI/EusLaDOjDDMCo=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  cargoBuildFlags = [
    "--package=ralph-cli"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Ralph Orchestrator - Multi-agent orchestration framework for autonomous AI development";
    homepage = "https://github.com/mikeyobrien/ralph-orchestrator";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux ++ platforms.darwin;
  };

  passthru.skipCi = true;
}
