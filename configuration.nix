
{ config, pkgs, ... }:

{
  # hardware e módulos
  imports = [
    ./hardware-configuration.nix
    ./modules/rgb-keyboard.nix
  ];

  # boot e inicialização
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # identidade e rede
  networking.hostName = "0kauaa";
  networking.networkmanager.enable = true;

  # data, hora e idioma
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # interface gráfica e teclado
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  console.keyMap = "br-abnt2";

  # áudio e impressão
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # usuário
  users.users.kauaa = {
    isNormalUser = true;
    description = "0kauaa";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # programas e pacotes
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # navegadores
    brave

    # desenvolvimento
    git
    tree
    vscode
    opencode-desktop

    # ambiente python global
    (python3.withPackages (ps: with ps; [
      pip
    ]))

    # ambiente haskell global
    ghc
    cabal-install
    stack

    # extensões do sistema
    gnomeExtensions.dash-to-dock
    direnv
    nix-direnv

    # apps
    spotify
    libreoffice-qt

    # dicionários do libreoffice
    (hunspell.withDicts (dicts: with hunspellDicts; [
      pt_BR
      en_US
      en_GB-large
      en_CA
      en_AU
    ]))
  ];

  # overlay para corrigir o vscode
  nixpkgs.overlays = [
    (final: prev: {
      vscode = prev.vscode.overrideAttrs (old: {
        postPatch = builtins.replaceStrings
          [
            "resources/app/node_modules/@vscode/ripgrep/bin/rg"
          ]
          [
            "resources/app/node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-x64/rg"
          ]
          (old.postPatch or "");
      });
    })
  ];

  # configurações do Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
  ];

  # fontes
  fonts.packages = with pkgs; [
    fira-code
  ];

  # versão inicial do sistema
  system.stateVersion = "26.05";
}
