{ buildNpmPackage
, fetchurl
, makeWrapper
, lib
, pkgs
, fromFlake ? false
, ...
}:

buildNpmPackage rec {
  pname = "ralphy";
  version = "4.5.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/ralphy-cli/-/ralphy-cli-${version}.tgz";
    sha256 = "/hwKwlsIOplkk+4HltPHynwJo3/kY5l6UGATTAAKA5o=";
  };

  npmDepsHash = "sha256-K8QoMjoFoTWusOknhXU//r0roVNx8JdBuQNfUplv6Fg=";

  nativeBuildInputs = [ makeWrapper ];

  dontNpmBuild = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ralphy \
      --add-flags "$out/lib/node_modules/ralphy-cli/bin.js"
  '';

  distPhase = ":";

  meta = with lib; {
    description = "Ralphy - Autonomous AI Coding Loop";
    homepage = "https://github.com/michaelshimeles/ralphy";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };

  passthru = {
    skipCi = true;
  };
}
