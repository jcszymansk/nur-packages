{ pkgs, ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "vim-aider";
  version = "unstable-2025-04-30";
  src = pkgs.fetchFromGitHub {
    owner = "GeorgesAlkhouri";
    repo = "nvim-aider";
    rev = "3d1d733a7a3cf726dc41d1c4f15df01d208c09e5";
    sha256 = "1jsidi6p4ms1c14z782snvv33ji4j75ajn8dcah6cjgvxnj8fc78";
    meta.homepage = "https://github.com/GeorgesAlkhouri/nvim-aider";
  };
}
