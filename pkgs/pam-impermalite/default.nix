{ pam }:

pam.overrideAttrs (prev: {
  pname = "pam-impermalite";
  patches = prev.patches ++ [ ./symlinked-shadow.patch ./mod-unix-only.patch ];
  outputs = [ "out" ];

  preFixup = ''
    rm -f $out/lib/lib*
    rm -rf $out/sbin
  '';

  postFixup = ''
    mod=$out/lib/security/pam_unix.so
    patchelf --add-rpath ${pam}/lib $mod
  '';
})
