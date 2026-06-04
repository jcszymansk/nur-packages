{ buildNpmPackage
, fetchurl
, lib
, nodejs_24
, node-gyp
, python3
, ...
}:

let
  buildNpmPackage' = buildNpmPackage.override { nodejs = nodejs_24; };
in
buildNpmPackage' rec {
  pname = "caveman-code";
  version = "0.65.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@juliusbrussee/caveman-code/-/caveman-code-${version}.tgz";
    sha256 = "sha256-p1U3iw45xpIoXO1SAeq0fCgUnouEzovaS12gWO9Xi6o=";
  };

  npmDepsHash = "sha256-3yGB6PeHp1e74ZWmbT0ik3kjzV594dntgXDpzSszfqc=";
  dontNpmBuild = true;
  makeCacheWritable = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    awk '
      /"node_modules\/onnxruntime-common": \{/ { skip = 1; next }
      /"node_modules\/onnxruntime-node": \{/ { skip = 1; next }
      skip && /^[[:space:]]*},$/ { skip = 0; next }
      !skip { print }
    ' package-lock.json \
      | grep -v '"onnxruntime-common": "1.26.0"' \
      | grep -v '"onnxruntime-node": "\^1.20.0"' \
      > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json
  '';

  nativeBuildInputs = [
    (python3.withPackages (ps: with ps; [ distutils ]))
    node-gyp
  ];

  meta = with lib; {
    description = "Terminal coding harness with token-saving caveman mode";
    homepage = "https://github.com/JuliusBrussee/caveman-code";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "caveman";
  };

  passthru.skipCi = true;
}
