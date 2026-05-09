{ symlinkJoin
, makeWrapper
, sqlcl
, jdk
, ...
}:

let mysqlcl = sqlcl.overrideAttrs (_: {
  installPhase = ''
    mkdir -p $out/libexec
    mv * $out/libexec/

    makeWrapper $out/libexec/bin/sql $out/bin/sqlcl \
      --set JAVA_HOME ${jdk.home}
  '';
});
in
symlinkJoin {
  name = "sqlcl-${sqlcl.version}-with-utils";
  paths = [ mysqlcl ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    # orapki
    makeWrapper ${jdk.home}/bin/java $out/bin/orapki \
      --add-flags "-classpath ${sqlcl}/libexec/lib/oraclepki.jar" \
      --add-flags "oracle.security.pki.textui.OraclePKITextUI"

    # mkstore
    makeWrapper ${jdk.home}/bin/java $out/bin/mkstore \
      --add-flags "-classpath ${sqlcl}/libexec/lib/oraclepki.jar" \
      --add-flags "oracle.security.pki.OracleSecretStoreTextUI"
  '';

  meta = sqlcl.meta // {
    description = "${sqlcl.meta.description} (with orapki and mkstore utilities)";
    mainProgram = "sqlcl";
  };
}
