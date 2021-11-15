#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

export LIBVA_DRIVER_NAME='vdpau'
export VDPAU_DRIVER='nvidia'
export LIBVA_DRIVERS_PATH='/usr/lib/dri'
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORMTHEME="qt5ct"
xrandr --output DVI-D-0 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-0 --off --output DP-1 --off &
sxhkd &
setxkbmap -option caps:escape
redshift &
dunst $HOME/.config/dunst/dunstrc_xr_colors &
picom &
udiskie &
nm-applet &
unclutter --timeout 3 &
wal -R &
$HOME/.fehbg &
$HOME/.local/bin/mpd_start &

dwmblocks &
while true; do
  dwm >/dev/null 2>&1
done
