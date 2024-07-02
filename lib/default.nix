lib:

let
  inherit (import ./importers.nix lib) rakeLeaves flattenTree;
in
with lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  loaddir = loadfn: path: mapAttrs loadfn (flattenTree (rakeLeaves path));

}
