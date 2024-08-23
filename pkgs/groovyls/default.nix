{ lib, openjdk_headless, buildGradlePackage, fetchFromGitHub, ... }:

buildGradlePackage rec {
  pname = "groovyls";
  version = "unstable-2024-06-28"; #
  src = fetchFromGitHub {
    owner = "GroovyLanguageServer";
    repo = "groovy-language-server";
    rev = "7be0244a1a58a144c382ee95a22fcc7ce9662706";
    sha256 = "1s32xwkf0697ak43mwnm22hvx962radramlq4fsw48sxgqckk9l5";
  };
  lockFile = ./gradle.lock;
  gradleBuildFlags = [ "build" ];

  installPhase = ''
    mkdir -p $out/share/java
    cp build/libs/source-all.jar $out/share/java/groovyls.jar
    mkdir -p $out/bin
    cat > $out/bin/${pname} <<EOF
#!/bin/sh
exec ${lib.getExe openjdk_headless} -jar $out/share/java/groovyls.jar "\$@"
EOF
    chmod +x $out/bin/${pname}
  '';
}
