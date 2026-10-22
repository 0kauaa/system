{ config, pkgs, ... }:

{
  # Hardware e módulos
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot e inicialização
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Identidade e rede
  networking.hostName = "0kauaa";
  networking.networkmanager.enable = true;

  # Data, hora e idioma
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

  # Interface gráfica e teclado
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };
  console.keyMap = "br-abnt2";

  # Áudio e impressão
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Usuário
  users.users.kauaa = {
    isNormalUser = true;
    description = "0kauaa";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };


# Programas e pacotes
programs.nix-ld.enable = true;
environment.systemPackages = with pkgs; [
  # Navegadores
  brave

  # Desenvolvimento
  git
  vscode
  opencode-desktop

  # Ambiente Haskell global
  ghc
  cabal-install
  stack

  # Extensões do GNOME
  gnomeExtensions.dash-to-dock

  # Aplicativos
  spotify
];

  # Configurações do Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-41.10.7"
  ];

  # Teclado: controle da iluminação RGB
  environment.etc."scrolllock-rgb.py".text = ''
    import glob
    import time
    import evdev
    from evdev import ecodes

    LED_PATHS = "/sys/class/leds/*scrolllock*/brightness"
    KEYBOARD_NAME = "USB USB Keyboard"

    def set_leds(value):
        for path in glob.glob(LED_PATHS):
            try:
                with open(path, "w") as led:
                    led.write(str(value) + "\n")
            except OSError as error:
                print("Erro ao controlar LED:", error, flush=True)

    while True:
        keyboard = None

        try:
            for path in evdev.list_devices():
                device = evdev.InputDevice(path)
                capabilities = device.capabilities().get(
                    ecodes.EV_KEY, []
                )

                if (
                    device.name == KEYBOARD_NAME
                    and ecodes.KEY_SCROLLLOCK in capabilities
                    and ecodes.KEY_A in capabilities
                ):
                    keyboard = device
                    break

                device.close()

            if keyboard is None:
                print("Aguardando teclado USB...", flush=True)
                time.sleep(2)
                continue

            print(
                "Monitorando: " + keyboard.name + " em " + keyboard.path,
                flush=True,
            )

            state = 0
            set_leds(state)

            for event in keyboard.read_loop():
                if (
                    event.type == ecodes.EV_KEY
                    and event.code == ecodes.KEY_SCROLLLOCK
                    and event.value == 1
                ):
                    state = 1 - state
                    set_leds(state)
                    print(
                        "RGB: " + ("ligado" if state else "desligado"),
                        flush=True,
                    )

                elif event.type == ecodes.EV_LED:
                    time.sleep(0.05)
                    set_leds(state)

        except (OSError, IOError) as error:
            print("Teclado desconectado: " + str(error), flush=True)

        finally:
            if keyboard is not None:
                keyboard.close()

        time.sleep(2)
  '';

  systemd.services.scrolllock-rgb = {
    description = "Controle RGB do teclado via Scroll Lock";

    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];

    serviceConfig = {
      Type = "simple";

      ExecStart =
        "${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3 /etc/scrolllock-rgb.py";

      Restart = "always";
      RestartSec = "2s";
    };
  };

  # Versão inicial do sistema
  system.stateVersion = "26.05";
}
