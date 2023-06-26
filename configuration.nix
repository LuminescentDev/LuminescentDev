# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ./host.nix
  ];

  # idk
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # Networking
  networking.hostName = "luminescent-nix";
  networking.domain = "";

  # Time Zone
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    wget
    git
    gnumake
    thefuck
    neofetch
    nodejs
    nodePackages_latest.pnpm
    nodePackages_latest.pm2
    openssl
    prisma-engines
    direnv
    nix-direnv
  ];

  # nix options for derivations to persist garbage collection
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysql = {
        ssl-ca = "/etc/mysql/ssl/ca-cert.pem";
        ssl-cert = "/etc/mysql/ssl/client-cert.pem";
        ssl-key = "/etc/mysql/ssl/client-key.pem";
      };
      mysqld = {
        ssl-ca = "/etc/mysql/ssl/ca-cert.pem";
        ssl-cert = "/etc/mysql/ssl/server-cert.pem";
        ssl-key = "/etc/mysql/ssl/server-key.pem";
      };
    };
    ensureDatabases = [
      "AK_BasementBot"
      "AK_BasementBotBeta"
      "AK_VRCDB"
      "LD_Cactie"
      "LD_CactieDev"
      "LD_CactieTesting"
      "ND_DiscordSRV"
      "ND_LiteBans"
      "ND_LuckPerms"
      "ND_MarriageMaster"
      "ND_VotingPlugin"
    ];
  };
  
  # Use zsh instead of bash
  programs.zsh = {
    enable = true;
    shellAliases = {
      nix-update = "nixos-rebuild switch";
      nix-edit = "nano /etc/nixos/configuration.nix";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "robbyrussell";
    };
  };
  users.defaultUserShell = pkgs.zsh;

  # Allow ports through firewall
  networking.firewall = {
    allowedTCPPorts = [ 443 80 3306 6480 22480 55718 58720 ];
    allowedUDPPorts = [ 443 80 3306 6480 22480 55718 58720 ];
  };

  # Caddy webserver
  services.caddy = {
    enable = true;
    email = "sab@luminescent.dev";
    virtualHosts."transcript.luminescent.dev".extraConfig = ''
      reverse_proxy http://localhost:6480
    '';
    virtualHosts."cactiewh.luminescent.dev".extraConfig = ''
      reverse_proxy http://localhost:58720
    '';
    virtualHosts."cactiedevwh.luminescent.dev".extraConfig = ''
      reverse_proxy http://localhost:55718
    '';
    virtualHosts."phpmyadmin.luminescent.dev".extraConfig = ''
      reverse_proxy http://localhost:22480
    '';
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.containers = {
    "phpmyadmin" = {
      image = "beeyev/phpmyadmin-lightweight:latest";
      environment = {
        PMA_HOST = "nix.luminescent.dev";
        UPLOAD_LIMIT = "1G";
        TZ = "America/New_York";
      };
      ports = [ "22480:80" ];
    };
  };

  # Enable the OpenSSH daemon
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQClcG+DpF4yyG3GbOdI5lcKhN/10iYw/OnnRf0H77HGygaw0ifmN2JKeoorih4qyruYLRt2HTLuk+wFAqfRkGEdBhuVDOfOgQIxvkZDu7TTZ1fkZrmPcrBraXPtzbWTU/juEwMHg9XmaOgaFYRAT6OtqwGCBdGrSpNSSHi84A/1ZwPY5Ujugxx4GQiAcAUxmj5GhxuE84zQ03uzXvatDlRZ0qRX9+tqZpZQIQMaElQyVm+YlmMWw5iL5cR5ysMECwxg+hfsCivwAMqcd/w9mUrILQVUqXKkszXQEm2HJz6lh5Lo1vRu73K+dF9wLO9cm5gpxr+9Vag4z1moVnO/7lv4c1XX9k4Oe/93pMsOvjm7gyKAKnJ85qIaxTZL+7RhO56opPi4bHHXHJlDkifWr+U/MclMUKXFwlPrNdhB0A4ofkUFpaSz+yJQ8zN/rJQrBnIFKaAZvHq/155Ls5d+h+2Wy59THsPFHRsR17nrb6rhcKKviT1BZihGa3ksqw6M5ws= sab@nixos'' 
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
