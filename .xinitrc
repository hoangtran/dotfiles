#!/bin/sh
#
# ~/.xinitrc
#

eval `cat $HOME/.fehbg` &                   # set background
numlockx on &                               # numlock on
setxkbmap -option terminate:ctrl_alt_bksp & # C-A-BS to kill X
urxvtd -q -f -o &                           # start urxvt daemon
xcompmgr -fF &                              # allow transparency
xrdb $HOME/.Xresources &                    # load Xresources
#xset fp+ /usr/share/fonts/local &           # add local fonts
xset s 1200 1200 &                          # set monitor to sleep 20 mins
xsetroot -cursor_name left_ptr              # req'd for xmonad's cursor
(sleep 3 && xmodmap $HOME/.Xmodmap) &       # remove capslock
unclutter &				    # hide mouse cursors
uim-xim &
xcape -e 'Control_L=Escape' &		    # press then release will send esc.

xmonad		                            # start xmonad
