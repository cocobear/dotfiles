# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

zmodload zsh/zprof


# For zplug
#source /usr/local/opt/zplug/init.zsh
source ~$USER/.zplug/init.zsh
zplugs=()
zplug "zplug/zplug"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/extract",   from:oh-my-zsh
zplug "plugins/vi-mode",   from:oh-my-zsh

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

# For oh-my-zsh
# Path to your oh-my-zsh installation.
#export ZSH="/Users/cocobear/.oh-my-zsh"
#
#ZSH_THEME="powerlevel9k/powerlevel9k"
#
#plugins=(
# zsh-syntax-highlighting
# zsh-autosuggestions
# vi-mode
# git
# extract
# #bgnotify
#)
#
#source $ZSH/oh-my-zsh.sh

# add a function path
fpath=(~$USER/.config/functions $fpath)
autoload ${fpath[1]}/*(:t)


export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# using GNU ls
eval "$(gdircolors ~/.dircolors)"
alias ls='gls --group-directories-first --color=auto'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# color ssh
source $HOME/.config/functions/iTerm2-ssh
alias ssh="colorssh"

# prompt_context() {
#  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
  #  prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
#  fi
# }

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red') # To have commands starting with `rm -rf` in red:


# FOR THEME powerlevel9k
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
# FOR THEME solarized
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=10'

############################
#### FOR POWERLEVEL9K ######
############################
POWERLEVEL9K_MODE='nerdfont-complete'
DEFAULT_USER=cocobear
POWERLEVEL9K_ALWAYS_SHOW_USER=false
POWERLEVEL9K_CONTEXT_TEMPLATE="%n"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time vi_mode)
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%b%f%k%F{blue}%} %{%f%}"

# eval $(thefuck --alias)
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/opt/node@10/bin:$PATH"
export PATH="./bin:$HOME/bin:/usr/local/sbin:$PATH"
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

[[ -s "/usr/local/etc/grc.zsh" ]] && source /usr/local/etc/grc.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_COMMAND='fd –type f –follow –exclude .git'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
