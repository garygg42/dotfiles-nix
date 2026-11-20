{ config, pkgs, ... }:

{
  security.sudo.wheelNeedsPassword = false;

  programs.fish.enable = true;

  users.users."username" = {
    isNormalUser = true;
    description = "username";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
    ];
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
