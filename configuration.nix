# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with pkgs;
let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    # other python packages you want
  ]; 
  python-with-my-packages = python3.withPackages my-python-packages;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./tmux.nix
      ./synergy.nix
      ./samba.nix
      ./redshift.nix
      ./hidpi.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  #networking.interfaces.enp6s0.useDHCP = true;
  networking.interfaces.enp6s0.ipv4.addresses = [{
        address = "192.168.199.7";
        prefixLength = 28;
      }];
  networking.defaultGateway = "192.168.199.1";
  networking.nameservers = [ "192.168.199.20" "192.168.199.8" ];
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "none+xmonad";
  services.xserver.windowManager = {
 #    qtile.enable = true;
     xmonad.enable = true;
#     xmonad.config= ./xmonad.hs;
     xmonad.enableContribAndExtras = true;
     xmonad.extraPackages = hpkgs: [
       hpkgs.xmonad
       hpkgs.xmonad-contrib
       hpkgs.xmonad-extras
       hpkgs.dbus
     ];
#     default = "xmonad";
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  nixpkgs.config.allowUnfree = true;
  hardware.pulseaudio.enable = true;
  hardware.enableAllFirmware = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

  # virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
  
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.szhou = {
     isNormalUser = true;
     extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ]; # Enable ‘sudo’ for the user.
   };
  
   security.sudo.wheelNeedsPassword = false;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     python-with-my-packages
     wget spotify
     # browser
     firefox google-chrome chromium
     git 
     #terminal
     alacritty kitty xfce.xfce4-terminal
     # file manager
     pcmanfm mc xfce.thunar
     # editor
     emacs vim neovim
     xmobar
     nitrogen
     # xmonad staff
     dmenu  conky  picom trayer
     feh 
     haskellPackages.libmpd
     haskellPackages.xmobar
     haskellPackages.dbus
     libnotify
     killall
     xscreensaver synergy 
     variety volumeicon unclutter pywal
     xfce.xfce4-power-manager
     xfce.xfce4-notifyd flameshot
     nm-tray xsettingsd pasystray
     arandr gmrun redshift
     compton  nitrogen betterlockscreen 
     polkit_gnome caffeine-ng polybar
     networkmanagerapplet
     # chat tool
     slack discord
     # screenshot tool
     scrot
     # media player
     vlc mplayer
     #clipboard tools
     clipit clipman xclip
     # office
     libreoffice
     # shell
     zsh oh-my-zsh
     # admin
     htop tmux bind dig
     # zip tool
     unrar unzip
     # other
     redshift python2Full python38 jq
     xorg.xrdb playerctl tree
     # gvolpe
     bat docker-compose docker ncdu
     exa prettyping fish
     # rss
     newsboat
   ];

   # for redshift
   location = {
    provider = "manual";
    latitude = -33.8718;
    longitude = 151.2494;
  };


 # pinyin input
 i18n.inputMethod = {
  enabled = "fcitx";
  fcitx.engines = with pkgs.fcitx-engines; [ cloudpinyin libpinyin];
};


  environment.variables.GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ]; # lets PCManFM discover gvfs modules
  
  # configure my zsh
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
    interactiveShellInit = ''
      # z - jump around
      source ${pkgs.fetchurl {url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10";}}
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh
      export ZSH_THEME="robbyrussell"
      plugins=(git)
      source $ZSH/oh-my-zsh.sh
    '';
    promptInit = "";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      font-awesome
      font-awesome_4
      open-sans
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      wqy_microhei
      wqy_zenhei
    ];
  };
 

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

