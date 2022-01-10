{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.username = "kita";
  home.packages = with pkgs; [
    powershell
    git
    exa
    ghq
    peco
    pet
    ffmpeg
    youtube-dl
    azure-cli
    docker
    terraform
    direnv
    slack
    discord
    vscode
    obs-studio
  ];
}
