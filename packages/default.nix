
# centralização dos pacotes personalizados

{ pkgs }:

{
  # opencode
  opencode-automatico = import ./opencode.nix {
    inherit pkgs;
  };

  # sklauncher
  sklauncher = import ./sklauncher.nix {
    inherit pkgs;
  };

  # uaitex
  uaitex = import ./uaitex.nix {
    inherit pkgs;
  };
}
