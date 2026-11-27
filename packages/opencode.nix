
# pacote personalizado para o opencode

{ pkgs }:

pkgs.writeShellApplication {
  name = "opencode";

  # adiciona programas ao path durante a execução para que o script consiga encontrar node.js, bun e git.
  runtimeInputs = with pkgs; [
    nodejs_22
    bun
    git
  ];

  # comando executado quando o opencode é chamado.
  text = ''
    exec ${pkgs.nodejs_22}/bin/npx --yes opencode-ai@latest "$@"
  '';
}
