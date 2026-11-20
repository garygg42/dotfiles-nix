# /etc/nixos/networking.nix
{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.udev.extraRules = ''
    ...
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

}
