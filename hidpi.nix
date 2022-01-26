{ config, pkgs, ... }:

{
   # Ref: https://stackoverflow.com/a/49732140/55246
   services.xserver.displayManager.sessionCommands = ''
   ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xft.dpi: 192
      Xcursor.theme: Adwaita
      Xcursor.size: 58
   EOF
   '';
   # Increase touchpad/trackpoint speed. 1.0 is maximum speed.
   # Changing this value won't take effect until X restart.
   services.xserver.libinput.touchpad.accelSpeed = "0.5";
}
