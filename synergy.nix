{ config, pkgs, ... }:
{
 # setup synergy.nix
 environment.etc."synergy-server.conf" = { text = ''
  section: screens
    ENC-UK-4735:
  	nixos:
  end
  section: aliases
    ENC-UK-4735:
      192.168.199.11
  	nixos:
      192.168.199.7
	section: links
    ENC-UK-4735:
			right = nixos
		nixos:
			left = ENC-UK-4735
	end
  ''; };
  services = {
    synergy.server = {
       enable = true;
       autoStart = true;
       screenName = "nixos";
       address = "192.168.199.7";
       configFile = "/etc/synergy-server.conf";
    };
  };
}