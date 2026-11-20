# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # НИКОГДА не включать вместе с NetworkManager

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.udev.extraRules = ''
    # Не отдавать порты полётников ModemManager'у
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ENV{ID_MM_DEVICE_IGNORE}="1"

    # Права на USB-устройства полётников (WebUSB и DFU)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28e9", MODE="0666"
  '';
  # # ===== Wi-Fi hotspot средствами NetworkManager =====
  # # NM сам не создаёт виртуальные интерфейсы — ap0 создаёт юнит ниже.
  # # Дальше всё делает NM: канал синхронизируется с клиентской сетью,
  # # dnsmasq (DHCP+DNS) и iptables (NAT) включаются при активации.
  # # Аплинк не нужен: AP работает всегда, интернет появляется,
  # # как только wlo1 куда-то подключится.
  #
  # # NM нужны бинари dnsmasq и iptables для режима shared
  # systemd.services.NetworkManager.path = with pkgs; [
  #   dnsmasq
  #   iptables
  # ];
  #
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  #
  # # Создание виртуального интерфейса ap0 на карте wlo1.
  # # Ретраи нужны, чтобы не соревноваться с wpa_supplicant за карту при загрузке.
  # systemd.services.wlan-ap0 = {
  #   description = "Create ap0 virtual WLAN interface for NM hotspot";
  #   bindsTo = [ "sys-subsystem-net-devices-wlo1.device" ];
  #   after = [
  #     "sys-subsystem-net-devices-wlo1.device"
  #     "NetworkManager.service"
  #   ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #     ExecStartPre = "-${pkgs.iproute2}/bin/ip link del ap0";
  #     ExecStart =
  #       let
  #         createAp = pkgs.writeShellScript "create-ap0" ''
  #           ok=0
  #           for i in $(${pkgs.coreutils}/bin/seq 1 30); do
  #             if ${pkgs.iw}/bin/iw dev wlo1 interface add ap0; then ok=1; break; fi
  #             echo "retry $i: waiting for wlo1..." >&2
  #             ${pkgs.coreutils}/bin/sleep 2
  #           done
  #           [ "$ok" = 1 ] || exit 1
  #           ${pkgs.iproute2}/bin/ip link set ap0 address 02:00:00:00:00:02
  #           ${pkgs.iproute2}/bin/ip link set ap0 up
  #         '';
  #       in
  #       [ "${createAp}" ];
  #   };
  # };
  #
  # networking.networkmanager.ensureProfiles.profiles.hotspot = {
  #   connection = {
  #     id = "hotspot";
  #     type = "wifi";
  #     autoconnect = "true";
  #     permissions = "";
  #     interface-name = "ap0";
  #   };
  #   wifi = {
  #     mode = "ap";
  #     ssid = "devpi-hotspot";
  #   };
  #   wifi-security = {
  #     key-mgmt = "wpa-psk";
  #     psk = "Shawarma0077";
  #   };
  #   ipv4 = {
  #     method = "shared";
  #     address1 = "192.168.12.1/24,192.168.12.1";
  #   };
  #   ipv6.method = "ignore";
  # };
  #
  # # Клиентам хотспота нужны DHCP и DNS
  # networking.firewall.interfaces."ap0" = {
  #   allowedUDPPorts = [
  #     53
  #     67
  #     68
  #   ];
  #   allowedTCPPorts = [ 53 ];
  # };
  # # ===== конец Wi-Fi hotspot =====

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";
  # time.timeZone = "Asia/Jerusalem";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "username"
  ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.flatpak.enable = true;

  # services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # security.sudo.extraConfig = ''
  #   Defaults env_editor
  #   Defaults editor=/run/current-system/sw/bin/nvim
  # '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."username" = {
    isNormalUser = true;
    description = "username";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  programs.nix-ld.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  # NVIDIA driver for RTX 4090 Laptop GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-битные библиотеки — их требует docker.enableNvidia
  };

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # Intel: 0000:00:02.0
      intelBusId = "PCI:0@0:2:0";

      # NVIDIA: 0000:01:00.0
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia-container-toolkit.mounts = [
    {
      hostPath = "/etc/nvidia-container-egl/10_nvidia.json";
      containerPath = "/usr/share/glvnd/egl_vendor.d/10_nvidia.json";
    }
  ];

  programs.fish.enable = true;

  users.users.username.shell = pkgs.fish;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  nixpkgs.overlays = [
    (final: prev: {
      opencode = prev.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs (_: {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        });
      });
    })
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    mesa-demos
    pciutils
    jq
    git
    neovim
    vscode
    opencode
    fuse
    appimage-run
    telegram-desktop
    uv
    tmux
    onlyoffice-desktopeditors
    wezterm
    vlc
    slack
    klassy
    gcc
    gnumake
    tree-sitter
    stylua
    ripgrep
    unzip
    nodejs
    _7zz
    obs-studio
    wireguard-tools
    rpi-imager
    chromium
    tcpdump
    iw
    lazygit
    gdu
    gparted
    wl-clipboard
    linux-wifi-hotspot
    rustc
    cargo
    rustfmt
    clippy
  ];

}
