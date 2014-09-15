#!/usr/bin/env bash

# forked from https://github.com/riobard/bash-powerline
__powerline() {

  ## USER CONFIG ##
  readonly max_path_depth=3

  ## standard fonts
  # ▷ ◣ ▶︎ ➤ 〉  $ % ⑂ + ⇡ ⇣
  ## for powerline patched fonts
  # █       

  # Symbols Config
  readonly git_branch_changed_symbol='+'
  readonly git_need_push_symbol='⇡'
  readonly git_need_pull_symbol='⇣'

  # This is working for me, but I need to figure out
  # a good way to indicate whether we should use
  # powerline-fonts or not.
  if [[ $TERM = "xterm-16color" ]]; then
    # use standard fonts
    readonly prompt_divider=''
    readonly git_branch_symbol='⑂'
  else # use powerline-fonts
    readonly prompt_divider=''
    readonly git_branch_symbol=''
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

  readonly fg_yelllow="\[$(tput setaf 3)\]"  #yellow
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
    if (__is_git_branch); then

      # get current branch name or short SHA1 hash for detached head
      local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
      [ -n "$branch" ] || return  # git branch not found

      local marks

      # branch is modified?
      [ -n "$(git status --porcelain)" ] && marks+=" $git_branch_changed_symbol"

      # how many commits local branch is ahead/behind of remote?
      local stat="$(git status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
      local aheadN="$(echo $stat | grep -o 'ahead \d\+' | grep -o '\d\+')"
      local behindN="$(echo $stat | grep -o 'behind \d\+' | grep -o '\d\+')"
      [ -n "$aheadN" ] && marks+=" $git_need_push_symbol$aheadN"
      [ -n "$behindN" ] && marks+=" $git_need_pull_symbol$behindN"

      # print the git branch segment without a trailing newline
      printf "$git_branch_symbol$branch$marks"
    fi
  }

  # guidance from https://github.com/Hexcles/bash-powerline
  __pwd() {
    local pwd=$(pwd)

    # substitude ~ for $HOME
    local pwd=$(sed -e "s|^$HOME|~|" <<< $pwd)

    # get an array of directories
    local split=(${pwd//\// })
    # count how many backslashes
    local pathDepth=${#split[@]}

    # calculate index of last element
    lastPosition=$((pathDepth-1))

    # Substitude '  ' for instances of '/'
    pwd=$(sed -e "s|/|  |g" <<< $pwd)

    if [[ $pwd = ~* ]]; then
      # shorten path if more than 2 directories lower than home
      if [[ $pathDepth > $max_path_depth ]]; then
        pwd="~  ...  ${split[lastPosition]}"
      fi
    else
      # In other than home, shorten path when greater than 3
      # directories deep.
      if [[ $pathDepth > $max_path_depth ]]; then
        pwd="/  ${split[0]}   ...   ${split[lastPosition]}"
      else
        # append a backslash to the front of pwd
        pwd=$(sed -e "s|^ |/  |" <<< $pwd)
      fi
    fi
    echo -n $pwd
  }

  ps1() {
    # Check the exit code of the previous command and display different
    # colors in the prompt accordingly.
    if [ $? -ne 0 ]; then
      local bg_exit="$bg_red"
      local fg_exit="$fg_red"
    else
      local bg_exit="$bg_green"
      local fg_exit="$fg_green"
    fi

    PS1=""

    # username
    if [[ $(whoami) == "root" ]]; then
      PS1+="$bg_red$fg_base3 \u $reset_colors"
      PS1+="$bg_base00$fg_red$prompt_divider$reset_colors"
    else
      PS1+="$bg_blue$fg_base3 \u $reset_colors"
      PS1+="$bg_base00$fg_blue$prompt_divider$reset_colors"
    fi

    # path
    PS1+="$bg_base00$fg_base3 $(__pwd) $reset_colors"

    # git status
    if (__is_git_branch); then
      PS1+="$bg_base01$fg_base00$prompt_divider$reset_colors"
      PS1+="$bg_base01$fg_base1 $(__git_info) $reset_colors"
      PS1+="$bg_exit$fg_base01$prompt_divider$reset_colors"
    else
      PS1+="$bg_exit$fg_base00$prompt_divider$reset_colors"
    fi
    # segment transition
    PS1+="$fg_exit$prompt_divider$reset_colors "
  }

  PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
