{ pkgs, ... }:

let
  revision = "54263c09110125e6b78f2f46ea2ab32c6fbd49f8";
  upstream = (fetchTarball {
    url = "https://github.com/vlaci/openconnect-sso/archive/${revision}.zip";
    sha256 = "099nbs74pnkqq4aaw9lb8mc6zibcw0a9h0pa6aia9srlffgpiqb5";
  });
in 
  (import "${upstream}/nix" { inherit pkgs; }).openconnect-sso.overrideAttrs (prev: {
    patches = [ ./profile.patch ];
  })

