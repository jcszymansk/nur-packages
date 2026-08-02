{ pkgs, ... }:

pkgs.linux-wifi-hotspot.overrideAttrs (previous: {
  patches = (previous.patches or [ ]) ++ [ ./bind-interfaces.patch ];
})
