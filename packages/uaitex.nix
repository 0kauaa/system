
# pacote personalizado para o uaitex
{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "uaitex";
  version = "1.3.8";

  # baixa o pacote debian original
  src = pkgs.fetchurl {
    url = "https://uaitex.uaifisica.com.br/downloads/UaiTex-1.3.8-Linux-amd64.deb";
    hash = "sha256-qY1trVFs7rplcVkQ3mwP+GTozdYc3oK6Q21nk6tPnCQ=";
  };

  # ferramentas utilizadas durante a construção
  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # bibliotecas compartilhadas necessárias pelo electron
  buildInputs = with pkgs; [
    gtk3
    glib
    nss
    nspr
    alsa-lib
    libgbm
    libdrm
    libxkbcommon
    libXScrnSaver
    libXtst
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxshmfence
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    expat
    libGL
    pango
    cairo
    atk
    gdk-pixbuf
  ];

  # extrai o conteúdo do pacote debian sem instalá-lo no sistema
  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  # instala os arquivos nos diretórios do pacote nix
  installPhase = ''
    runHook preInstall

    # preserva a estrutura original esperada pelo aplicativo
    mkdir -p "$out/opt"
    cp -r opt/uaitex "$out/opt/uaitex"

    # cria o executável que ficará disponível no path
    mkdir -p "$out/bin"

    # o wrapper disponibiliza ferramentas externas necessárias
    makeWrapper "$out/opt/uaitex/uaitex" "$out/bin/uaitex" \
      --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}"

    # instala o atalho do aplicativo
    mkdir -p "$out/share/applications"
    substitute usr/share/applications/uaitex.desktop \
      "$out/share/applications/uaitex.desktop" \
      --replace-fail "/opt/uaitex/uaitex" "$out/bin/uaitex"

    # instala os ícones do aplicativo
    cp -r usr/share/icons "$out/share/"

    runHook postInstall
  '';

  # metadados do pacote
  meta = with pkgs.lib; {
    description = "Editor LaTeX com compilação offline e visualização de PDF";
    homepage = "https://uaitex.uaifisica.com.br";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "uaitex";
  };
}
