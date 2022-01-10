{ config, pkgs, options, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Tokyo";

  networking = {
    hostName = "brazingstar";
    useDHCP = false;
    interfaces.enp4s0 = {
      useDHCP = false;
      ipv4.addresses = [ {
        address = "192.168.100.12";
        prefixLength = 24;
      } ];
    };
    defaultGateway = "192.168.100.1";
    nameservers = [ "192.168.100.1" ];
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod.enabled = "fcitx";
    inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    layout = "us";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.kita = {
    isNormalUser = true;
    home = "/home/kita";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtaUnpWsDZtAwpMUNC48lU6+tafEadIRaWZUJAaJnWl" ];
  };

  programs.steam.enable = true;
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    zsh
    vim
    wget
    home-manager
    brave
    docker
    barrier
  ];

  virtualisation.docker.enable = true;

  fonts.fonts = with pkgs; [
    myrica
    jetbrains-mono 
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "21.11"; # Did you read the comment?
}
