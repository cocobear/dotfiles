# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

zmodload zsh/zprof

# SHOULD before theme load
POWERLEVEL9K_MODE='nerdfont-complete'

# For zplugin
# Added by Zplugin's installer
source ~/.zplugin/bin/zplugin.zsh
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk
zplugin ice silent wait"0" atload"_zsh_autosuggest_start"
zplugin load "zsh-users/zsh-autosuggestions"
#zplugin load "zsh-users/zsh-syntax-highlighting"

zplugin ice silent wait"0" blockf
zplugin load "zsh-users/zsh-completions"

zplugin ice silent wait"0" atinit"zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

zplugin ice silent wait'0'
zplugin load zdharma/history-search-multi-word

zplugin snippet OMZ::lib/git.zsh
zplugin snippet OMZ::plugins/git/git.plugin.zsh
zplugin snippet OMZ::plugins/vi-mode/vi-mode.plugin.zsh
zplugin snippet OMZ::plugins/extract/extract.plugin.zsh
zplugin snippet OMZ::plugins/brew/brew.plugin.zsh
zplugin snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

# [Theme]
zplugin ice from"gh"
zplugin load bhilburn/powerlevel9k
zplugin light chrissicool/zsh-256color


# For zplug
#export ZPLUG_HOME=/usr/local/opt/zplug
#source $ZPLUG_HOME/init.zsh
#zplugs=()
#zplug "zplug/zplug"
#zplug "zsh-users/zsh-autosuggestions"
#zplug "zsh-users/zsh-completions"
#zplug "zsh-users/zsh-syntax-highlighting"
#zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
#zplug "robbyrussell/oh-my-zsh", as:plugin, use:"lib/*.zsh"
#
#zplug "plugins/git",   from:oh-my-zsh
#zplug "plugins/gitfast",   from:oh-my-zsh
#zplug "plugins/extract",   from:oh-my-zsh
#zplug "plugins/vi-mode",   from:oh-my-zsh
#zplug "plugins/colored-man-pages", from:oh-my-zsh
#
#zplug "knu/z", use:z.sh, defer:3
#zplug "rupa/z", as:plugin, use:z.sh
#zplug "b4b4r07/enhancd", use:init.sh
#zplug "rimraf/k"
#zplug "zsh-users/zsh-history-substring-search"
#zplug 'wfxr/forgit'
#
## Install plugins if there are plugins that have not been installed
#if ! zplug check --verbose; then
#    printf "Install? [y/N]: "
#    if read -q; then
#        echo; zplug install
#    fi
#fi
#
#zplug load

# For oh-my-zsh
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


alias vi='nvim'
alias vim='nvim'
# add a function path
fpath=(~$USER/.config/functions $fpath)
autoload ${fpath[1]}/*(:t)


export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
unsetopt INC_APPEND_HISTORY
unsetopt APPEND_HISTORY
export EDITOR=vim


# using GNU ls
eval "$(gdircolors ~/.dircolors)"
alias ls='gls --group-directories-first --color=auto'
alias ls='exa --group-directories-first'
alias ll='ls -alh --group-directories-first --git --time-style=iso'
alias la='ls -a --group-directories-first'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zsh tab completion : case-insensitive matching only if there are no case-sensitive matches
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'


# color ssh
source $HOME/.config/functions/iTerm2-ssh
# alias ssh="colorssh"
[[ -n "$TMUX" ]] && unalias ssh || alias ssh="colorssh"
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
DEFAULT_USER=cocobear
POWERLEVEL9K_ALWAYS_SHOW_USER=false
POWERLEVEL9K_CONTEXT_TEMPLATE="%n"
#POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
if [ -z "$TMUX" ]; then
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir virtualenv anaconda vcs)
else
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=()

fi
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
POWERLEVEL9K_STATUS_VERBOSE=false
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%b%f%k%F{blue}%} %{%f%}"

# eval $(thefuck --alias)
export MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

[[ -s "/usr/local/etc/grc.zsh" ]] && source /usr/local/etc/grc.zsh

# for FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_COMMAND='fd –type f –follow –exclude .git'
# export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules,dist,env}/*" -g "!*.{swp,pyc}" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=dark
--color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
--color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
'
FZF_CTRL_R_OPTS="--preview-window down:3 --preview 'echo {}'"
FZF_CTRL_R_OPTS='--no-height -m --preview-window=right --preview="highlight -O ansi -l --force {}"'
bindkey -s '^p' 'vim $(fzf)\n'


tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
     tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
# fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
fshow() {
  local out shas sha q k
  while out=$(
      git log --graph --color=always \
          --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
      fzf --ansi --multi --no-sort --reverse --query="$q" \
      --preview "echo {} | grep -o '[a-f0-9]\{7\}' | head -1 |
                 xargs -I % sh -c 'git show --color=always % | head -$LINES'" \
          --print-query --expect=ctrl-d --toggle-sort=\`); do
    q=$(head -1 <<< "$out")
    k=$(head -2 <<< "$out" | tail -1)
    shas=$(sed '1,2d;s/^[^a-z0-9]*//;/^$/d' <<< "$out" | awk '{print $1}')
    [ -z "$shas" ] && continue
    if [ "$k" = ctrl-d ]; then
      git diff --color=always $shas | less -R
    else
      for sha in $shas; do
        git show --color=always $sha | less -R
      done
    fi
  done
}

# brew bottles中科大镜像
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/opt/node@10/bin:$PATH"
export PATH="./bin:$HOME/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/miniconda3/bin:$PATH"
source /usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh
