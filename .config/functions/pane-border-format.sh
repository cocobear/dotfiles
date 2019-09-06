#!/bin/zsh

# color variables
INACTIVE_BORDER_COLOR='#cccccc'
ACTIVE_BORDER_COLOR='#00afff'

BLACK='#000000'
WHITE='#ffffff'
YELLOW='#f4f899'
GREEN='#3CF87D'
BROWN='#C69DFD'


_branch=''
branch=''
misc=''

# read args
for i in "$@"
do
    case $i in
        --pane-current-path=*)
            PANE_CURRENT_PATH="${i#*=}"
            shift # past argument=value
            ;;
        --pane-active=*)
            PANE_ACTIVE="${i#*=}"
            shift # past argument=value
            ;;
        *) # unknown option
            ;;
    esac
done

# replace full path to home directory with ~
PRETTY_PATH=$(sed "s:^$HOME:~:" <<< $PANE_CURRENT_PATH)

if [ -z $PRETTY_PATH ]; then
    PRETTY_PATH=~/dotfiles/
fi
# calculate reset color
RESET_BORDER_COLOR=$([ $PANE_ACTIVE -eq 1 ] && echo $ACTIVE_BORDER_COLOR || echo $INACTIVE_BORDER_COLOR)

color () {
    INTENT=$1
    echo $([ $PANE_ACTIVE -eq 1 ] && echo $INTENT || echo $INACTIVE_BORDER_COLOR)
}

# git functions adapted from the bureau zsh theme
# https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/bureau.zsh-theme
get_git_type () {
    cd $PANE_CURRENT_PATH
    local remote=$(command git ls-remote --get-url 2> /dev/null)
    if [[ "$remote" =~ "github" ]]; then
        vcs_visual_identifier=
    elif [[ "$remote" =~ "bitbucket" ]]; then
        vcs_visual_identifier=
    elif [[ "$remote" =~ "stash" ]]; then
        vcs_visual_identifier=
    elif [[ "$remote" =~ "gitlab" ]]; then
        vcs_visual_identifier=
    else
        vcs_visual_identifier=
    fi
    echo $vcs_visual_identifier

}
ZSH_THEME_GIT_PROMPT_PREFIX="$(get_git_type)""  "
ZSH_THEME_GIT_PROMPT_SUFFIX=" "
ZSH_THEME_GIT_PROMPT_CLEAN="#[fg=$(color $GREEN)]#[fg=$RESET_BORDER_COLOR]"
ZSH_THEME_GIT_PROMPT_AHEAD=" "
ZSH_THEME_GIT_PROMPT_BEHIND=" "
ZSH_THEME_GIT_PROMPT_STAGED=" "
ZSH_THEME_GIT_PROMPT_UNSTAGED=" "
ZSH_THEME_GIT_PROMPT_UNTRACKED=" "
ZSH_THEME_GIT_PROMPT_UNMERGED=" ✹"

git_branch () {
    #ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    #ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
    #branch="${ref#refs/heads/}"
    ref=$(command git symbolic-ref HEAD 2> /dev/null)
    _branch="${ref#refs/heads/}"
    branch=" ${ref#refs/heads/}"
}

git_tagname() {
    # If we are on a tag, append the tagname to the current branch string.
    local tag
    local data
    tag=$(command git describe --tags --exact-match HEAD 2>/dev/null)

    if [[ -n "${tag}" ]] ; then
        # There is a tag that points to our current commit. Need to determine if we
        # are also on a branch, or are in a DETACHED_HEAD state.
        if [[ -z $(command git symbolic-ref HEAD 2>/dev/null) ]]; then
            # DETACHED_HEAD state. We want to append the tag name to the commit hash
            # and print it. Unfortunately, `vcs_info` blows away the hash when a tag
            # exists, so we have to manually retrieve it and clobber the branch
            # string.
            local revision
            revision=$(command git rev-list -n 1 --abbrev-commit --abbrev=8 HEAD)
            branch="  ${revision}  ${tag}"
        else
            # We are on both a tag and a branch; print both by appending the tag name.
            branch+="  ${tag}"
        fi
    fi
}
git_status () {
    _STATUS=""

  # check status of files
  _INDEX=$(command git status --porcelain 2> /dev/null)
  if [[ -n "$_INDEX" ]]; then
      if $(echo "$_INDEX" | command grep -q '^[AMRD]. '); then
          _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
      fi
      if $(echo "$_INDEX" | command grep -q '^.[MTD] '); then
          _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
      fi
      if $(echo "$_INDEX" | command grep -q -E '^\?\? '); then
          _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
      fi
      if $(echo "$_INDEX" | command grep -q '^UU '); then
          _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
      fi
  fi

  echo $_STATUS
}

git_stash() {
    local -a stashes

    if [[ -s $(command git rev-parse --git-dir 2>/dev/null)/refs/stash ]] ; then
        stashes=$(command git stash list 2>/dev/null | wc -l)
        misc+="   ${stashes}"
    fi
}
git_aheadbehind() {
    local ahead behind
    ahead=$(command git rev-list --count "${_branch}"@{upstream}..HEAD 2>/dev/null)
    (( ahead )) && misc+=" $ZSH_THEME_GIT_PROMPT_AHEAD $ahead"

    behind=$(command git rev-list --count HEAD.."${branch}"@{upstream} 2>/dev/null)
    (( behind )) && misc+=" $ZSH_THEME_GIT_PROMPT_BEHIND ${behind}"

}
git_prompt () {
    local _status=$(git_status)
    local _result=""
    local git_info=""
    git_branch
    git_tagname
    git_aheadbehind
    git_stash
    #echo " #[fg=#282c34,bg=#C69DFD,bold] $(get_remote_info)#[fg=#C69DFD,bg=#3CF87D,bold]#[fg=#282c34,bg=#3CF87D,bold]   master  #[fg=#3CF87D,bg=#24272e,bold]"

    if [[ "${branch}x" != "x" ]]; then
        git_info="$git_info$ZSH_THEME_GIT_PROMPT_PREFIX$branch"
        if [[ "${_status}x" != "x" ]]; then
            git_info="$git_info $_status"
        fi

        if [[ "${misc}x" != "x" ]]; then
            git_info="$git_info $misc  "
        fi
        git_info="$git_info"
    fi

    if [[ "${_status}"x != "x" ]]; then
        _result="$_result #[fg=$BLACK,bg=$(color $BROWN),bold] 
        $(get_remote_info) #[fg=$(color $BROWN),bg=$(color $YELLOW),bold]
        #[fg=$BLACK,bg=$(color $YELLOW),bold] "
        _result="$_result $git_info #[fg=$(color $YELLOW),bg=#282c34,bold]"
    else
        _result="$_result #[fg=$BLACK,bg=$(color $BROWN),bold] 
        $(get_remote_info) #[fg=$(color $BROWN),bg=$(color $GREEN),bold]
        #[fg=$BLACK,bg=$(color $GREEN),bold] "
        _result="$_result $git_info #[fg=$(color $GREEN),bg=#282c34,bold]"
    fi
    echo $_result
}

parse_ssh_port() {
    # If there is a port get it
    local port=$(echo $1|grep -Eo '\-p ([0-9]+)'|sed 's/-p //')

    if [ -z $port ]; then
        local port=22
    fi

    echo $port
}

get_ssh_user() {
    local ssh_user=$(whoami)

    for ssh_config in `awk '
        $1 == "Host" {
        gsub("\\\\.", "\\\\.", $2);
        gsub("\\\\*", ".*", $2);
        host = $2;
        next;
    }
$1 == "User" {
$1 = "";
sub( /^[[:space:]]*/, "" );
printf "%s|%s\n", host, $0;
}' ~/.ssh/config`; do
local host_regex=${ssh_config%|*}
local host_user=${ssh_config#*|}
if [[ "$1" =~ $host_regex ]]; then
    ssh_user=$host_user
    break
fi
done

echo $ssh_user
}

ssh_connected() {
    # Get current pane command
    local cmd=$(tmux display-message -p "#{pane_current_command}")

    [ $cmd = "ssh" ] || [ $cmd = "sshpass" ]
}
get_remote_info() {
    local command=$1

  # First get the current pane command pid to get the full command with arguments
  local cmd=$({ pgrep -flaP `tmux display-message -p "#{pane_pid}"` ; ps -o command -p `tmux display-message -p "#{pane_pid}"` ; } | xargs -I{} echo {} | grep ssh | sed -E 's/^[0-9]*[[:blank:]]*ssh //')

  local port=$(parse_ssh_port "$cmd")

  local cmd=$(echo $cmd|sed 's/\-p '"$port"'//g')

  local user=$(echo $cmd | awk '{print $NF}'|cut -f1 -d@)
  local host=$(echo $cmd | awk '{print $NF}'|cut -f2 -d@)

  if [ $user == $host ]; then
      local user=$(get_ssh_user $host)
  fi

  if ssh_connected; then
      echo "$user@$host:$port"
  else
      echo $PRETTY_PATH
  fi
}


# final output
dir_bg='#3CF87D'
echo $(cd $PANE_CURRENT_PATH && git_prompt)

#echo " #[fg=#282c34,bg=#C69DFD,bold] $(get_remote_info) #[fg=#C69DFD,bg=$(color $YELLOW),bold]$(cd $PANE_CURRENT_PATH && git_prompt) "
#echo " #[fg=#282c34,bg=#C69DFD,bold] $(get_remote_info)#[fg=#C69DFD,bg=#3CF87D,bold]#[fg=#282c34,bg=#3CF87D,bold]   master  #[fg=#3CF87D,bg=#24272e,bold]"
#echo $(cd $PANE_CURRENT_PATH && get_git_type)
