{ pkgs, stdenv, upstream, ... }:

upstream.overrideAttrs (_: {
  meta.broken = !stdenv.isLinux;
})
