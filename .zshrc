# TODO: https://wiki.archlinux.org/index.php/Color_output_in_console

[[ -s '/etc/zsh_command_not_found' ]] && source '/etc/zsh_command_not_found'

export CLICOLOR=1
export LESS='--window -2 -FMRX'

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias vi='vim'

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


################################################################################
# Platform-specific behaviors
################################################################################
# Based on Lubuntu 19.10 ~/.bashrc

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [[ -n "$DISPLAY" ]]; then
   export TERM=xterm-256color

   man() {
       env \
           LESS_TERMCAP_mb=$(printf "\e[1;31m") \
           LESS_TERMCAP_md=$(printf "\e[1;31m") \
           LESS_TERMCAP_me=$(printf "\e[0m") \
           LESS_TERMCAP_se=$(printf "\e[0m") \
           LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
           LESS_TERMCAP_ue=$(printf "\e[0m") \
           LESS_TERMCAP_us=$(printf "\e[1;32m") \
           man "$@"
   }
fi


################################################################################
# Somewhat bash-like History
################################################################################
HISTFILE=~/.zsh_history
HISTSIZE=9999
SAVEHIST=9999
HISTFILESIZE=9999
unsetopt hist_beep
unsetopt inc_append_history
unsetopt share_history
setopt append_history
setopt hist_find_no_dups
setopt hist_reduce_blanks
#setopt histignorealldups


################################################################################
# Misc. zsh settings
################################################################################
autoload -Uz compinit
#for dump in ~/.zcompdump(N.mh+24); do
#    # https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
#    # Section "What else is slow then?"
#    compinit
#done
compinit

#-------------------------------------------------------------------------------
# These are auto-generated by Lubuntu 19.10
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
#-------------------------------------------------------------------------------


################################################################################
# Bash-like keystrokes
################################################################################
source ~/.zshrc-keybindings.linux


################################################################################
# Enriched prompt
################################################################################
autoload -Uz vcs_info && vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats ' (%b)'
setopt PROMPT_SUBST
precmd() { vcs_info }
aws_profile() {
    # For https://github.com/remind101/assume-role/ which adds ASSUME_ROLE
    # to the current shell process.
    local assumed_role=""
    if [[ -n "$ASSUMED_ROLE" ]]; then
        assumed_role="%B%F{yellow}$ASSUMED_ROLE%f%b"
    fi

    # Isengard cli spanws a new shell process.
    local profile_name=""
    if [[ -n "$AWS_DEFAULT_PROFILE" ]]; then
        profile_name="%B%F{red}$AWS_DEFAULT_PROFILE%f%b"
    elif [[ -n "$AWS_PROFILE" ]]; then
        profile_name="%B%F{red}$AWS_PROFILE%f%b"
    fi

    if [[ -n "$profile_name" && -n "$assumed_role" ]]; then
        echo -n " %F{white}[$profile_name, $assumed_role%F{white}]"
    elif [[ -n "$assumed_role" ]]; then
        echo -n " %F{white}[$assumed_role%F{white}]"
    elif [[ -n "$profile_name" ]]; then
        echo -n " %F{white}[$profile_name%F{white}]"
    fi
}

prompt_prefix() {
    local retval=""

    # Be aware when some CLI toolkits (e.g., assume role) spawns a new shell.
    [[ ${SHLVL} -gt 1 ]] && retval=${retval}"%B%F{yellow}[${SHLVL}]%f%b "

    # Be aware when running under midnight commander.
    [[ -v MC_SID ]] && retval=${retval}"%B%F{red}[mc]%f%b "

    echo -n "${retval}"
}

# Must use single quote for vsc_info_msg_0_ to work correctly
#export PROMPT='$(prompt_prefix)%F{cyan}%n@%F{green}%m:%F{white}%~%B%F{magenta}${vcs_info_msg_0_}%b$(aws_profile)%F{gray}
export PROMPT='$(prompt_prefix)[%B%F{green}%~%b%F{white}]%B%F{magenta}${vcs_info_msg_0_}%b$(aws_profile)%F{gray}
%# '

# Trick `less` to believe screen size has one-less line.
if [[ -z "$SSH_TTY" ]]; then
    # This causes a minor annoyance: after vim, must `reset`.
    function winch_handler() {
        setopt localoptions nolocaltraps
        COLUMNS=$(tput cols)
        LINES=$(expr `tput lines` - $1)
        stty rows $LINES cols $COLUMNS
    }
    winch_handler 1
    trap 'winch_handler 1' WINCH
fi
