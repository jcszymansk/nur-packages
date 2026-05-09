{
  lib,
  fetchFromGitHub,
  fetchurl,
  maven,
  makeWrapper,
  jre,
  ...
}:

maven.buildMavenPackage rec {
  pname = "utplsql-cli";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "utPLSQL";
    repo = "utPLSQL-cli";
    rev = "v${version}";
    hash = "sha256-toflkrfDHekc5NZUb4Eg0ypGC5wcqP2J2TbQRBo1Dj0=";
  };

  patches = [
    (fetchurl {
      url = "https://github.com/Drako-PxPx/utPLSQL-cli/commit/30b293970eff2a273e8681c87e71e1aaac13917c.patch";
      hash = "sha256-soHdDRiRiB2/HstnBk6v4XSKcJsoenmN9IMG8x0fh2o=";
    })
  ];

  mvnHash = "sha256-2EYIwzXPIud4IBkkMOKmaEAS+sar17kbDjVP1vzVYXY=";
  mvnParameters = "appassembler:assemble";

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec
    cp -r target/appassembler/. $out/libexec/

    mkdir -p $out/bin
    makeWrapper $out/libexec/bin/utplsql $out/bin/utplsql \
      --prefix PATH : ${lib.makeBinPath [ jre ]} \
      --set JAVA_HOME ${jre}

    runHook postInstall
  '';

  meta = {
    description = "Command line client for invoking utPLSQL";
    homepage = "https://github.com/utPLSQL/utPLSQL-cli";
    license = lib.licenses.asl20;
    mainProgram = "utplsql";
  };
}
