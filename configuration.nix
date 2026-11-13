# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

let
  # ===== Wi-Fi hotspot: раздача интернета от второй Wi-Fi сети =====
  sta = "wlo1";  # клиентский интерфейс (интернет отеля)
  ap  = "ap0";   # виртуальный интерфейс точки доступа (та же карта)
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # nixpkgs.config.problems.handlers."gtk+".broken = "warn";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # ===== Wi-Fi hotspot: AP на ap0, интернет от wlo1 =====

  systemd.services.wlan-ap0 = {
    description = "Create ap0 virtual WLAN interface for hotspot";
    bindsTo = [ "sys-subsystem-net-devices-wlo1.device" ];
    after = [ "sys-subsystem-net-devices-wlo1.device" ];
    before = [ "hostapd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStartPre = "-${pkgs.iproute2}/bin/ip link del ap0";
      ExecStart = [
        "${pkgs.iw}/bin/iw dev wlo1 interface add ap0 type managed"
        "${pkgs.iproute2}/bin/ip link set ap0 address 02:00:00:00:00:02"
        "${pkgs.iproute2}/bin/ip addr add 192.168.12.1/24 dev ap0"
        "${pkgs.iproute2}/bin/ip link set ap0 up"
      ];
      ExecStop = "${pkgs.iproute2}/bin/ip link del ap0";
    };
  };

  # wpa_supplicant (бэкенд NM) — только клиентский интерфейс, не ap0
  networking.wireless.interfaces = [ sta ];

  # Точка доступа на канале 11 — том же, где клиент (иначе не заведётся)
  services.hostapd = {
    enable = true;
    radios.${ap} = {
      band = "2g";
      channel = 11;
      networks.${ap} = {
        ssid = "devpi-hotspot";
        authentication = {
          mode = "wpa2-sha256";
          wpaPassword = "Shawarma0077";
        };
      };
    };
  };

  # DHCP + DNS для клиентов AP
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = ap;
      bind-interfaces = true;
      dhcp-range = "192.168.12.10,192.168.12.200,255.255.255.0,12h";
      server = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  # NAT: клиенты ap0 выходят в интернет через wlo1
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nat = {
    enable = true;
    internalInterfaces = [ ap ];
    externalInterface = sta;
  };

  # Пропустить DHCP/DNS для клиентов через фаервол
  networking.firewall.interfaces.${ap} = {
    allowedUDPPorts = [ 53 67 ];
    allowedTCPPorts = [ 53 ];
  };

  # NM не должен управлять ap0
  networking.networkmanager.unmanaged = [ "interface-name:ap0" ];

  # ===== конец Wi-Fi hotspot =====

  # Set your time zone.
  # time.timeZone = "Europe/Warsaw";
  time.timeZone = "Asia/Jerusalem";

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "username" ];

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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
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
    enable32Bit = true;   # 32-битные библиотеки — их требует docker.enableNvidia
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

  hardware.nvidia-container-toolkit.mounts = [{
    hostPath = "/etc/nvidia-container-egl/10_nvidia.json";
    containerPath = "/usr/share/glvnd/egl_vendor.d/10_nvidia.json";
  }];

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
  ];

}
