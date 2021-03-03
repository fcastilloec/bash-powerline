#!/usr/bin/env bash

# shellcheck disable=2001

# forked from https://github.com/cyberdork33/bash-powerline
__powerline() {

  ## USER CONFIG ##
  readonly MAX_PATH_DEPTH=3
  readonly PATH_SEPARATOR='/'

  ## standard fonts
  # ▷ ◣ ▶︎ ➤ 〉  $ % ⑂ + ⇡ ⇣
  ## for powerline patched fonts
  # █       

  # Symbols Config
  readonly GIT_BRANCH_CHANGED_SYMBOL='+'
  readonly GIT_NEED_PUSH_SYMBOL='⇡'
  readonly GIT_NEED_PULL_SYMBOL='⇣'

  # This is working for me, but I need to figure out
  # a good way to indicate whether we should use
  # powerline-fonts or not.
  if [[ $TERM = "xterm-16color" ]]; then
    # use standard fonts
    readonly PROMPT_DIVIDER=''
    readonly GIT_BRANCH_SYMBOL='⑂'
  else # use powerline-fonts
    readonly PROMPT_DIVIDER=''
    readonly GIT_BRANCH_SYMBOL=''
  fi

  # Solarized colorscheme
  readonly fg_base03="\[$(tput setaf 8)\]"  #brblacksource
  readonly fg_base02="\[$(tput setaf 0)\]"  #black
  readonly fg_base01="\[$(tput setaf 10)\]" #brgreen
  readonly fg_base00="\[$(tput setaf 11)\]" #bryellow
  readonly fg_base0="\[$(tput setaf 12)\]"  #brblue
  readonly fg_base1="\[$(tput setaf 14)\]"  #brcyan
  readonly fg_base2="\[$(tput setaf 7)\]"   #white
  readonly fg_base3="\[$(tput setaf 15)\]"  #brwhite

  readonly bg_base03="\[$(tput setab 8)\]"
  readonly bg_base02="\[$(tput setab 0)\]"
  readonly bg_base01="\[$(tput setab 10)\]"
  readonly bg_base00="\[$(tput setab 11)\]"
  readonly bg_base0="\[$(tput setab 12)\]"
  readonly bg_base1="\[$(tput setab 14)\]"
  readonly bg_base2="\[$(tput setab 7)\]"
  readonly bg_base3="\[$(tput setab 15)\]"

  readonly fg_yellow="\[$(tput setaf 3)\]"  #yellow
  readonly fg_orange="\[$(tput setaf 9)\]"  #brred
  readonly fg_red="\[$(tput setaf 1)\]"     #red
  readonly fg_magenta="\[$(tput setaf 5)\]" #magenta
  readonly fg_violet="\[$(tput setaf 13)\]" #brmagenta
  readonly fg_blue="\[$(tput setaf 4)\]"    #blue
  readonly fg_cyan="\[$(tput setaf 6)\]"    #cyan
  readonly fg_green="\[$(tput setaf 2)\]"   #green

  readonly bg_yellow="\[$(tput setab 3)\]"
  readonly bg_orange="\[$(tput setab 9)\]"
  readonly bg_red="\[$(tput setab 1)\]"
  readonly bg_magenta="\[$(tput setab 5)\]"
  readonly bg_violet="\[$(tput setab 13)\]"
  readonly bg_blue="\[$(tput setab 4)\]"
  readonly bg_cyan="\[$(tput setab 6)\]"
  readonly bg_green="\[$(tput setab 2)\]"

  readonly dim_colors="\[$(tput dim)\]"
  readonly reverse_colors="\[$(tput rev)\]"
  readonly reset_colors="\[$(tput sgr0)\]"
  readonly bold_colors="\[$(tput bold)\]"

  __is_git_branch() {
    if (hash git &> /dev/null); then
      git rev-parse --is-inside-work-tree &> /dev/null
      return $?
    fi
  }

  __git_info() {
    local branch
    local marks
    local stat
    local aheadN
    local behindN

    # get current branch name or short SHA1 hash for detached head
    branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
    [ -n "$branch" ] || return  # git branch not found

    # branch is modified?
    [ -n "$(git status --porcelain)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

    # how many commits local branch is ahead/behind of remote?
    stat="$(git status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
    aheadN="$(echo "$stat" | grep -o 'ahead \d\+' | grep -o '\d\+')"
    behindN="$(echo "$stat" | grep -o 'behind \d\+' | grep -o '\d\+')"
    [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
    [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

    # print the git branch segment without a trailing newline
    echo -n "$GIT_BRANCH_SYMBOL $branch$marks"
  }

  __get_pwd() {
    local my_pwd
    local split

    my_pwd=$(pwd)

    # substitute ~ for $HOME
    my_pwd=$(sed -e "s|^$HOME|~|" <<< "$my_pwd")

    local IFS='/'
    read -ra split <<< "$my_pwd"

    # count how many backslashes
    local pathDepth=${#split[@]}

    # calculate index of last element
    local lastPosition=$((pathDepth-1))

    # Substitute '/' for user's visual path separator
    [[ "$PATH_SEPARATOR" != '/' ]] && my_pwd=$(sed -e "s|/|$PATH_SEPARATOR|g" <<< "$my_pwd")

    if [[ $my_pwd = ~* ]]; then
      # shorten path if more than 2 directories lower than home
      if [[ $pathDepth > $MAX_PATH_DEPTH ]]; then
        my_pwd="~$PATH_SEPARATOR...$PATH_SEPARATOR${split[lastPosition]}"
      fi
    else
      # In other than home, shorten path when greater than 3 directories deep.
      if [[ $pathDepth > $MAX_PATH_DEPTH ]]; then
        [[ $PATH_SEPARATOR != '/' ]] && my_pwd="/$PATH_SEPARATOR" || my_pwd='/'
        my_pwd+="${split[1]}$PATH_SEPARATOR...$PATH_SEPARATOR${split[lastPosition]}"
      else
        # append a backslash to the front of pwd
        [[ "$PATH_SEPARATOR" != '/' ]] && my_pwd=$(sed -e "s|^|/|" <<< "$my_pwd")
      fi
    fi
    echo "$my_pwd"
  }

  ps1() {
    # Saves exit code of last run command
    exit_code=$?

    # Check if we're on a git directory and store it on is_git. 0 is true, any other value is false
    __is_git_branch
    is_git=$?

    local bg_exit
    local fg_exit

    # Display different colors in the prompt according to exit_code
    if [ $exit_code -ne 0 ]; then
      bg_exit="$bg_red"
      fg_exit="$fg_red"
    else
      if [[ $is_git -eq 0 ]]; then
        bg_exit="$bg_base03"
        fg_exit="$fg_base03"
      else
        bg_exit="$bg_base00"
        fg_exit="$fg_base00"
      fi
    fi

    PS1=""

    # username
    if [[ $(whoami) == "root" ]]; then
      PS1+="$bg_red$fg_base3 \u $reset_colors"
      PS1+="$bg_base00$fg_red$PROMPT_DIVIDER$reset_colors"
    else
      PS1+="$bg_blue$fg_base3 \u $reset_colors"
      PS1+="$bg_base00$fg_blue$PROMPT_DIVIDER$reset_colors"
    fi

    # path
    PS1+="$bg_base00$fg_base3 $(__get_pwd) $reset_colors"

    # git status
    if [[ $is_git -eq 0 ]]; then
      PS1+="$bg_base03$fg_base00$PROMPT_DIVIDER$reset_colors"
      PS1+="$bg_base03$fg_base02 $(__git_info) $reset_colors"
      PS1+="$bg_exit$fg_base03$PROMPT_DIVIDER$reset_colors"
    else
      PS1+="$bg_exit$fg_base00$PROMPT_DIVIDER$reset_colors"
    fi
    # segment transition
    PS1+="$fg_exit$PROMPT_DIVIDER$reset_colors "
  }

  PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
