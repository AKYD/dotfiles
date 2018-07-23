# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export PATH=$PATH:~/bin:~/bin/autojump/usr/local/bin

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# timestamp the commands in history
export HISTTIMEFORMAT="%F %T "

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
# expand history but don't execute
shopt -s histverify

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
fi

# make less keep the text on screen after exit
export LESS='FiXR'

alias l='ls -liAh'
alias ll='ls -liAh'
alias grep='grep --color=auto -i'
alias r='fc -s'
alias ..='cd ..'
alias ...='cd ../..'
alias g='history | grep'
alias diffss='diff --side-by-side -W"`tput cols`"'

export EDITOR=/usr/bin/vim

# expand all ! words
bind Space:magic-space


# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# colorize man pages
#export MANPAGER="/usr/bin/most -s"
# use vim for man pages
export MANPAGER="/bin/sh -c \"col -b | vim -c 'set ft=man ts=8 nomod nolist nonu noma' -\""

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

BLACK="\[\033[0;30m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
BROWN="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
PURPLE="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
LGRAY="\[\033[0;37m\]"

DGRAY="\[\033[1;30m\]"
LRED="\[\033[1;31m\]"
LGREEN="\[\033[1;32m\]"
YELLOW="\[\033[1;33m\]"
LBLUE="\[\033[1;34m\]"
LPURPLE="\[\033[1;35m\]"
LCYAN="\[\033[1;36m\]"
WHITE="\[\033[1;37m\]"
NORM="\[\e[m\]"

parse_git_dirty () {
            [[ $(git status 2> /dev/null | tail -n1 | cut -c 1-17) != "nothing to commit" ]] && echo "*"
}

parse_git_branch () {
        local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1/" )
        local dirty=$(parse_git_dirty)
        if [ -z "$branch" ]           
        then               
                echo ""
        else                                                                                
                if [ "$branch" == "master" ]
                then                     
                        branch="\001\033[1;31m\002${branch}\001\e[m\002"
                else
                        branch="\001\033[1;33m\002${branch}\001\e[m\002"                                                  
                fi
                                      
                if [ ! -z "$dirty" ]
                then
                        echo -e "( ${branch} : \001\e[33m\002*\001\e[m\002 ) "
                else
                        echo -e "( ${branch} ) "
                fi           
        fi                    
}                                                              
 
                     
# show last command exit status               
PS1="\`res=\$?; if [ \$res -eq 0 ]; then echo \[\e[32m\]^_^ \| \[\e[0m\]; else echo \[\e[31m\]O_o : \[\e[0m\]\[\e[35m\]\$res\[\e[0m\] \[\e[32m\]\| \[\e[0m\]; fi\`"

if [ $UID -eq 0 ]         
then                                                                                 
        PS1="$PS1""\[\e[1;31m\]${debian_chroot:+($debian_chroot)}\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]
"                       
else                                  
        PS1="$PS1""\[\e[1;32m\]${debian_chroot:+($debian_chroot)}\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]
"
fi                             
                    
PS1="$PS1 \$(parse_git_branch)"

# colorize prompt if logged in as root
if [ $UID -eq 0 ]
then
        PS1="$PS1\[\e[1;31m\]#\[\e[0m\] "
else
        PS1="$PS1\[\e[1;32m\]$\[\e[0m\] "
fi

PS4="${LRED}+${LGRAY}(${LGREEN}${BASH_SOURCE}:${YELLOW}${LINENO}${LGRAY}): ${LGRAY}${FUNCNAME[0]:+${FUNCNAME[0]}(): }"

export PS1
export PS4

########## Functions ########## 

genpasswd() {
	local l=$1
       	[ "$l" == "" ] && l=20
      	tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${l} | xargs
}

# determine which package contains the command
whichpkg () { dpkg -S $1 | egrep -w $(readlink -f "$(which $1)")$; }

# get info about a package
summpkg () { dpkg -s $(dpkg -S $1 | egrep -w $(which $1)$ | awk -F: '{print $1}') ; }

# tail -f with color
# example : t access.log ERROR WARNING
function t()
{
	file=$1
	unset string
	while (($#))
	do
		shift
		if [ "$1" ]
		then
			string="$string""s/""$1""/\e[1;$((31+$(($RANDOM%7))));40m$&\e[0m/g;"
		fi
	done
	tail -f $file | perl -pe "$string"
}


export LS_COLORS=$LS_COLORS":di=01;90"


function workspace ()
{
    tmux new -s Work -d
    tmux neww "vim -S tabs"
    tmux attach -t Work
}

# load proxy settings

[[ -r ~/dotfiles/proxyrc ]] && . ~/dotfiles/proxyrc

# load local settings
[[ -r ~/dotfiles/localrc ]] && . ~/dotfiles/localrc
                                                          
export PATH=~/.ssh:$PATH  

function ssh_with_rc()
{
        if [[ -r ~/.r_bashrc ]]
        then
                BASHRC_DATA=$(cat ~/.r_bashrc | base64 -w 0)
                VIMRC_DATA=$(cat ~/.r_vimrc | base64 -w 0)
                #\ssh -t $@ "echo \"${VIMRC_DATA}\" | base64 -di > /tmp/${USER}_vimrc; bash --rcfile <(echo \"${BASHRC_DATA}\" | base64 -di); rm -f /tmp/${USER}_vimrc"
                \ssh -t $@ "echo \"${VIMRC_DATA}\" | base64 -di > /tmp/${USER}_vimrc; echo \"${BASHRC_DATA}\" | base64 -di > /tmp/${USER}_bashrc; bash --rcfile /tmp/${USER}_bashrc; rm -f /tmp/${USER}_bashrc"
        else
                \ssh $@
        fi
}

alias ssh="ssh_with_rc"
