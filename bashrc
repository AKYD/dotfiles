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

alias l='ls -lisAh'
alias grep='grep --color=auto'
alias gpia='curl ifconfig.me'
alias r='fc -s'

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
                        branch="\e[1;31m$branch\e[m"
                else
                        branch="\e[1;33m$branch\e[m"
                fi

                if [ ! -z "$dirty" ]
                then
                        echo -e " ( ${branch} : \e[33m*\e[m ) "  
                else
                        echo -e " ( $branch ) "  
                fi
        fi
}


# show last command exit status
PS1="\`res=\$?; if [ \$res -eq 0 ]; then echo \[\e[32m\]^_^ \| \[\e[0m\]; else echo \[\e[31m\]O_o : \[\e[0m\]\[\e[35m\]\$res\[\e[0m\] \[\e[32m\]\| \[\e[0m\]; fi\`"

PS1="$PS1""\[\e[1;31m\]${debian_chroot:+($debian_chroot)}\u\[\e[0m\]@\[\e[1;33m\]\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]"


PS1="$PS1\`parse_git_branch\`"

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

# stop adobe from tracking stuff
adobenospy() { for I in ~/.adobe ~/.macromedia ; do ( [ -d $I ] && rm -rf $I ;  ln -s -f /dev/null $I ) ; done }

# calculator
calc() { bc <<< $*; }

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


function img
{
        for image in "$@"
        do
                convert -thumbnail $(tput cols) "$image" txt:- | awk -F '[)(,]' '!/^#/{gsub(/ /,""); printf"\033[48;2;"$3";"$4";"$5"m "}'
                echo -e "\e[0;0m"
        done
}


LS_COLORS='rs=0:di=01;90:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:'

# set up autojump
[[ -s /home/alinh/bin/autojump/etc/profile.d/autojump.sh ]] && . /home/alinh/bin/autojump/etc/profile.d/autojump.sh
