{ modulesPath, pkgs, lib, inputs, ... }:
{
  imports = [
    # Minimize the build to produce a smaller closure
    "${modulesPath}/profiles/minimal.nix"
  ];

  systemd.services.initialConfig = let
    copy-initial-config = pkgs.writeShellScript "copy-initial-config.sh" ''
      ${pkgs.coreutils}/bin/cp --no-preserve=mode ${inputs.self}/* /etc/nixos
    '';
  in {
    description = "Copy configuration into microvm";
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionDirectoryNotEmpty = "!/etc/nixos";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = copy-initial-config;
    };
  };

  # Should be pingable at clan-mobile.local via mDNS on first boot if clan hotspot is created
  networking.networkmanager.enable = false;
  networking.wireless = {
    enable = true;
    networks = {
      # default AP to connect to, for bootstrapping
      clan.psk = "givemeinternet";
    };
  };
  networking.hostName = "clan-mobile";
  services.avahi = {
    openFirewall = true;
    nssmdns4 = true; # Allows software to use Avahi to resolve.
    enable = true;
    publish = {
      userServices = true;
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.xserver.desktopManager.phosh = {
    enable = true;
    user = "default";
    group = "users";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-console       # Terminal
    vim
    git
  ];

  nixpkgs.config.allowUnfree = true;
  services.openssh.enable = true;

  users.users = {
    root.password = "default";
    default = {
      isNormalUser = true;
      password = "default";
      extraGroups = [
        "dialout"
        "feedbackd"
        "networkmanager"
        "video"
        "wheel"
      ];
    };
  };

  nix = {
    settings = {
      trusted-users = [ "@wheel" "root" ];
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;
      flake-registry = builtins.toFile "empty-flake-registry.json" ''{"flakes":[],"version":2}'';
      trust-tarballs-from-git-forges = true;
    };
    package = pkgs.nixVersions.latest;
    registry.nixpkgs.flake = lib.mkForce inputs.nixpkgs;
    registry.nixpkgs.to.path = lib.mkForce inputs.nixpkgs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

}
