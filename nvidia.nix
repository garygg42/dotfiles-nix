{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
}
