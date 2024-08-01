{ pkgs , ... }:

pkgs.openssh.overrideAttrs (prev: {
  # https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454
  patches = (prev.patches or []) ++ [ ./nocfgperms.patch ];
  doCheck = false;
})
