{ pam }:

pam.overrideAttrs (prev: {
  pname = "pam-impermanence";
  patches = prev.patches ++ [ ./symlinked-shadow.patch ];
})
