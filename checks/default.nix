inputs: {
  # switch to sops nix breaks the tests, we need to remeby that later
  "bind-test" = import ./bind-test.nix;
  # "kea-test" = import ./kea-test.nix inputs;
}
