#!/bin/sh
#
# Constructs the GDB "add-symbol-file" command string
# from the map file of the specified kernel module.

add_sect() {
    ADDR=`awk '/^'$1' / {print $3}' $MAPFILE`
    if [ "$ADDR" != "" ]; then
        echo "-s $1 `awk '/^'$1' / {print $3}' $MAPFILE`"
    fi
}

[ $# == 1 ] && [ -r "$1" ] || { echo "Usage: $0 <module>" >&2 ; exit 1 ; }

MAPFILE=$1.map

ARGS="`awk '/^.text / {print $3}' $MAPFILE`\
 `add_sect .rodata`\
 `add_sect .data`\
 `add_sect .sdata`\
 `add_sect .bss`\
 `add_sect .sbss`\
"

echo "add-symbol-file $1 $ARGS" > ~/.gdb/add-symbol-file.gdb
