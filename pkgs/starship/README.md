## Starship with presets

A nix build of Starship modified to expose TOML presets in `share/presets`.

It can then be used like this, e.g. in Home Manager:

```nix
programs.starship = let
  starship = nur.repos.jacekszymanski.starship-with-presets;
in
{
  enable = true;
  package = starship;
  settings =
    (with builtins; fromTOML (readFile "${starship}"/share/presets/plain-text-symbols.toml)) //
    {
      # overrides here
    };
};
```

or even combine presets in Nix:

```nix
programs.starship = let
  starship = nur.repos.jacekszymanski.starship-with-presets;
in
{
  enable = true;
  package = starship;
  settings = with builtins; lib.lists.foldl lib.attrsets.recursiveUpdate {} [
    (fromTOML (readFile "${starship}/share/presets/plain-text-symbols.toml"))
    (fromTOML (readFile "${starship}/share/presets/no-runtime-versions.toml"))
    {
      # own overrides
    }
  ];
};
```


