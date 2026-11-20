{ config, pkgs, ... }:

{
  networking.hostName = "nixos";

  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0483", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ENV{ID_MM_DEVICE_IGNORE}="1"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28e9", MODE="0666"
  '';

  # # ===== Wi-Fi hotspot средствами NetworkManager =====
  # # NM сам ставит хотспот на канал клиентской сети, запускает dnsmasq
  # # (DHCP+DNS) и iptables (NAT). AP работает и без аплинка; интернет
  # # у клиентов появляется, как только wlo1 подключится к какой-то сети.
  # # Выключить хотспот — закомментировать весь этот блок.
  # systemd.services.NetworkManager.path = with pkgs; [ dnsmasq iptables ];
  #
  # boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  #
  # # NM не создаёт виртуальные интерфейсы сам — ap0 делает этот юнит.
  # # Ретраи нужны, чтобы не соревноваться с wpa_supplicant за карту.
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
  #     ExecStart = let
  #       createAp = pkgs.writeShellScript "create-ap0" ''
  #         ok=0
  #         for i in $(${pkgs.coreutils}/bin/seq 1 30); do
  #           if ${pkgs.iw}/bin/iw dev wlo1 interface add ap0; then ok=1; break; fi
  #           echo "retry $i: waiting for wlo1..." >&2
  #           ${pkgs.coreutils}/bin/sleep 2
  #         done
  #         [ "$ok" = 1 ] || exit 1
  #         ${pkgs.iproute2}/bin/ip link set ap0 address 02:00:00:00:00:02
  #         ${pkgs.iproute2}/bin/ip link set ap0 up
  #       '';
  #     in [ "${createAp}" ];
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
  #   allowedUDPPorts = [ 53 67 68 ];
  #   allowedTCPPorts = [ 53 ];
  # };
  # # ===== конец Wi-Fi hotspot =====
}
