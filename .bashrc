# 
# .bashrc 
# 
# Hoang Tran <hoang.tran@greenwavereality.com>

# Check for an interactive session
[ -z "$PS1" ] && return

# is $1 installed?
_have() { which "$1" &>/dev/null; }

[[ -f $HOME/.dircolors ]] && eval $(/bin/dircolors -b $HOME/.dircolors)

source /usr/share/git/git-prompt.sh
source /usr/share/bash-completion/completions/git
source /usr/share/autojump/autojump.bash

set -o notify           # Tell me when bg proccess finish
set -o noclobber        # Warn of over write on redirects
set -o ignoreeof        # Ignore eof
set -o vi               # vi-like behavior for bash

shopt -s extglob

# disable flow control
stty -ixon

export BROWSER='firefox'
export EDITOR=vim
export BUILDROOT_DL_DIR=/hq/pkgs
export BR2_DL_DIR=/hq/pkgs
export LEGO_DOWNLOAD_DIR=/hq/pkgs
export LEGO_TOOLCHAIN_BASE=/opt/gws
export LEGO_DONT_BUILD_TOOLCHAIN=1
export NO_LICENSE_BUNDLE=1
export LESS='-R'
export TFTPDIR=/nfsroot
export INPUTRC='~/.inputrc'
export ACROBAT_PATH=/opt/Adobe/Reader9
export T32SYS=/opt/t32
export T32TMP=/tmp
export T32ID=T32

# HISTORY {{{

# don't put duplicate lines in the history. See bash(1) section 'HISTORY' for more options
#export HISTCONTROL="ignoredups"
# ... and ignore same sucessive entries, as well as commands starting with a space.
export HISTCONTROL="ignoreboth"

# store more stuff in the history...
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTTIMEFORMAT="[%DT%T] " # puts full date and time in history records.

# ignore relatively meaningless commands.
export HISTIGNORE="pwd:exit:clear:fg*:bg*:history*"

shopt -s histappend #makes bash append to history rather than overwrite

# store multiline commands as single entries in history file
shopt -s cmdhist

# allow re-editing of a history command substitution, if the previous run failed
shopt -s histreedit

# auto "cd" when entering just a path
shopt -s autocd

# }}}

### Overall conditionals/functions {{{

_islinux=false
[[ "$(uname -s)" =~ Linux|GNU|GNU/* ]] && _islinux=true

_isxrunning=false
[[ -n "$DISPLAY" ]] && _isxrunning=true

_isroot=false
[[ $UID -eq 0 ]] && _isroot=true

# }}}

# add directories to $PATH
_add_to_path() {
  local path

  for path in "$@"; do
    [[ -d "$path" ]] && [[ ! ":${PATH}:" =~ :${path}: ]] && export PATH=$PATH:${path}
  done
}

### Bash exports {{{

# set path
_add_to_path "$HOME/bin" "$HOME/oald8" "$T32SYS/bin/pc_linux64"

# custom log directory
[[ -d "$HOME/.logs" ]] && export LOGS="$HOME/.logs" || export LOGS='/tmp'

# screen tricks
if [[ -d "$HOME/.screen/configs" ]]; then
  export SCREEN_CONF_DIR="$HOME/.screen/configs"
  export SCREEN_CONF='main'
fi

# }}}

# modified commands

#eval "$(thefuck --alias)"

alias diff='colordiff'              # requires colordiff package
alias grep='grep --color=auto'
alias more='less'
alias m='more'
alias df='df -h'
alias du='du -c -h'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'

alias vi='vim'
alias emacs='emacs -nw'

# new commands
alias da='date "+%A, %B %d, %Y [%T]"'
alias du1='du --max-depth=1'
alias hist='history | grep $1'      # requires an argument
alias openports='netstat --all --numeric --programs --inet'
alias pg='ps -Af | grep $1'         # requires an argument

# mistakes
alias maek='make'
alias meak='make'

# privileged access
if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias scat='sudo cat'
    alias svim='sudo vim'
    alias root='sudo su'
    alias reboot='sudo reboot'
    alias netcfg='sudo netcfg'
fi

# cd
alias home='cd ~'
alias back='cd $OLDPWD'
alias cd..='cd ..'
alias ..='cd ..'

# ls
alias ls='ls -F --color=always'
alias lnc='ls -hF --color=never'
alias lr='ls -R'                    # recursive ls
alias ll='ls -l'
alias la='ll -A'
alias lx='ll -BX'                   # sort by extension
alias lz='ll -rS'                   # sort by size
alias lt='ll -rt'                   # sort by date
alias lm='la | more'

# safety features
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias g='git'

# gerrit commands
alias gerrit='ssh gitgerrit-01 gerrit'

# only if we have a screen_conf
if [[ -d "$SCREEN_CONF_DIR" ]]; then
  alias main='SCREEN_CONF=main screen -S main -D -R main'
  alias clean='SCREEN_CONF=clean screen -S clean -D -R clean'

  if _have rtorrent; then
    alias rtorrent='SCREEN_CONF=rtorrent screen -S rtorrent -R -D rtorrent'
    alias gtorrent='SCREEN_CONF=gtorrent screen -S gtorrent -R -D gtorrent'
  fi

  _have irssi && alias irssi='SCREEN_CONF=irssi screen -S irssi -R -D irssi'
fi

# equery
alias eqf='equery f'
alias equ='equery u'
alias eqh='equery h'
alias eqa='equery a'
alias eqb='equery b'
alias eql='equery l'
alias eqd='equery d'
alias eqg='equery g'
alias eqc='equery c'
alias eqk='equery k'
alias eqm='equery m'
alias eqy='equery y'
alias eqs='equery s'
alias eqw='equery w'

### Bash functions {{{

extract() {
  local e=0 i c
  for i; do
    if [[ -r $i ]]; then
        c=''
        case $i in
          *.t@(gz|lz|xz|b@(2|z?(2))|a@(z|r?(.@(Z|bz?(2)|gz|lzma|xz)))))
                 c='bsdtar xvf' ;;
          *.7z)  c='7z x'       ;;
          *.Z)   c='uncompress' ;;
          *.bz2) c='bunzip2'    ;;
          *.exe) c='cabextract' ;;
          *.gz)  c='gunzip'     ;;
          *.rar) c='unrar x'    ;;
          *.xz)  c='unxz'       ;;
          *.zip) c='unzip'      ;;
          *)     echo "$0: cannot extract \`$i': Unrecognized file extension" >&2; e=1 ;;
        esac
        [[ $c ]] && command $c "$i"
    else
        echo "$0: cannot extract \`$i': File is unreadable" >&2; e=2
    fi
  done
  return $e
}

# auto send an attachment from CLI 
send() {
  _have mutt || return 1

  echo 'Auto-sent from linux. Please see attached.' | mutt -s 'File Attached' -a "$1" "$2"
}

# run a bash script in 'debug' mode
debug() {
  local script="$1"; shift

  if _have "$script"; then
    PS4='+$LINENO:$FUNCNAME: ' bash -x "$script" "$@"
  fi
}

# go to a directory or file's parent
goto() { [[ -d "$1" ]] && cd "$1" || cd "$(dirname "$1")"; }

# copy and follow
cpf() { cp "$@" && goto "$_"; }

# move and follow
mvf() { mv "$@" && goto "$_"; }

# print the url to a manpage
webman() { echo "http://unixhelp.ed.ac.uk/CGI/man-cgi?$1"; }

# process / system toys
my_ps() { ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command ; }
pp() { my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"} ; }

# get IP adresses
my_ip() 
{
    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' | sed -e s/addr://)
    echo $MY_IP
}
 
function parse_git_dirty {
    echo -n $(git status 2>/dev/null | awk -v out=$1 -v std="dirty" '{ if ($0=="# Changes to be committed:") std = "uncommited"; last=$0 } END{ if(last!="" && last!="nothing to commit (working directory clean)") { if(out!="") print out; else print std } }')
}
function parse_git_branch {
    echo -n $(git branch --no-color 2>/dev/null | awk -v out=$1 '/^*/ { if(out=="") print $2; else print out}')
}
function parse_git_remote {
    echo -n $(git status 2>/dev/null | awk -v out=$1 '/# Your branch is / { if(out=="") print $5; else print out }')
}

# get current host related info
ii()   
{
    echo -e "\nYou are logged on ${RED}`hostname`"
    echo -e "\nAdditionnal information:$NC " ; uname -a
    echo -e "\n${RED}Users logged on:$NC " ; w -h
    echo -e "\n${RED}Current date :$NC " ; date
    echo -e "\n${RED}Machine stats :$NC " ; uptime
    echo -e "\n${RED}Memory stats :$NC " ; free
    echo -e "\n${RED}Local IP Address :$NC" ; echo ${MY_IP:-"Not connected"}
    echo
}

do_gwr()
{
    cd ~/gws/lego/
    source lego.env
}

do_ppc()
{
    export ARCH=powerpc
    export CROSS_COMPILE=powerpc-greenwave-linux-gnu-
    export GWRTOOLCHAIN=$LEGO_TOOLCHAIN_BASE/ppc405_gcc462
    _add_to_path "$GWRTOOLCHAIN/bin"
}

do_arm()
{
    export ARCH=arm
    export CROSS_COMPILE=arm-greenwave-linux-gnueabihf-
    export GWRTOOLCHAIN=$LEGO_TOOLCHAIN_BASE/arm-cortex-a9_linaro-gcc47
    _add_to_path "$GWRTOOLCHAIN/bin" $HOME/src/buildroot/output/host/usr/bin
}

do_mips()
{
    export ARCH=mips
    export CROSS_COMPILE=mips-greenwave-linux-gnu-
    export GWRTOOLCHAIN=$LEGO_TOOLCHAIN_BASE/mips-1074k_linaro-gcc47
    _add_to_path "$GWRTOOLCHAIN/bin"
}


# }}}

# less
if _have less; then
  export PAGER=less

  # these look terrible on a mac or in console
  if $_islinux && [[ "$TERM" != 'linux' ]]; then
    export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
    export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
    export LESS_TERMCAP_me=$'\E[0m'           # end mode
    export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
    export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
    export LESS_TERMCAP_ue=$'\E[0m'           # end underline
    export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
  fi
fi

#export LESS_TERMCAP_mb=$(printf "\e[1;37m")
#export LESS_TERMCAP_md=$(printf "\e[1;37m")
#export LESS_TERMCAP_me=$(printf "\e[0m")
#export LESS_TERMCAP_se=$(printf "\e[0m")
#export LESS_TERMCAP_so=$(printf "\e[1;47;30m")
#export LESS_TERMCAP_ue=$(printf "\e[0m")
#export LESS_TERMCAP_us=$(printf "\e[0;36m")

function env() {
  exec /usr/bin/env "$@" | grep -v ^LESS_TERMCAP_
}

# Todo alias
alias t='todo.sh'

# WELCOME SCREEN
#######################################################
#
#fortune -s $HOME/fortune/geek

#PS1="\[\e[0;31m\]┌── \u\[\e[m\] \[\e[1;34m\]\w\[\e[m\]\n\[\e[0;31m\]└─> \[\e[0m\]"
PS1='\[\e[0;31m\]┌─ [\h] \e[1;34m\]\w$(__git_ps1 " (%s)")\[\e[1;31m\]\n\[\e[0;31m\]└─> \[\e[0m\]'

### Starting X {{{

# auto startx if on tty1 and logout if/when X ends
if [[ $(tty) = /dev/tty1 ]] && ! $_isroot && ! $_isxrunning; then
  startx | tee "$LOGS/X.log"
  logout
fi

# }}}
