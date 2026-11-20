{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  programs.nix-ld.enable = true;

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
    opencode
    opencode-desktop
  ];
}
