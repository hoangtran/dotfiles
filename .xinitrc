#!/bin/sh
#
# ~/.xinitrc
#

# Full-range RGB (0-255); monitor HDMI Black Level must be Normal
xrandr --output DP-2 --set "Broadcast RGB" Full

sh $HOME/.fehbg &                           # set background
#numlockx on &                               # numlock on
setxkbmap -option terminate:ctrl_alt_bksp & # C-A-BS to kill X
urxvtd -q -f -o &                           # start urxvt daemon
#xcompmgr -fF &                             # replaced by picom (vsync)
picom -b &                                  # compositor with vsync, no tearing
xrdb $HOME/.Xresources &                    # load Xresources
#xset fp+ /usr/share/fonts/local &           # add local fonts
xset s 1200 1200 &                          # set monitor to sleep 20 mins
#xsetroot -cursor_name left_ptr              # req'd for xmonad's cursor
#(sleep 3 && xmodmap $HOME/.Xmodmap) &       # remove capslock
unclutter &				    # hide mouse cursors
#uim-xim &
xcape -e 'Control_L=Escape' &		    # press then release will send esc.

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
	for f in "/etc/X11/xinit/xinitrc.d"/?*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

exec i3
