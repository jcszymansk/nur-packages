{ openjdk_headless
, fetchurl
, stdenvNoCC
, lib
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "apache-camel-lsp";
  version = "1.23.0";

  jarName = "${pname}-${version}.jar";

  src = fetchurl {
    url = "https://repo1.maven.org/maven2/com/github/camel-tooling/camel-lsp-server/${version}/camel-lsp-server-${version}.jar";
    sha256 = "1snpndidwr8qrvyqs3swslq26q0bc813ncwiimf33zrb14ii91qd";
  };

  installPhase = ''
    mkdir -p $out/share/java
    cp $src $out/share/java/${jarName}

    mkdir -p $out/bin
    cat > $out/bin/${pname} <<EOF
#!/bin/sh
exec ${lib.getExe openjdk_headless} -jar $out/share/java/${jarName} "\$@"
EOF
    chmod +x $out/bin/${pname}
  '';

  dontUnpack = true;
  dontPatch = true;
  dontBuild = true;
  dontCheck = true;
  dontFixup = true;
}

