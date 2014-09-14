#!/usr/bin/env bash

# forked from https://github.com/riobard/bash-powerline

__powerline() {

    ## CONFIG
    readonly max_path_depth = 3

    ## standard fonts
    # ▷ ◣ ▶︎ ➤ 〉  $ % ⑂ + ⇡ ⇣

    ## for powerline patched fonts
    # █       

    # symbols
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
    readonly FG_BASE03="\[$(tput setaf 8)\]"  #brblacksource
    readonly FG_BASE02="\[$(tput setaf 0)\]"  #black
    readonly FG_BASE01="\[$(tput setaf 10)\]" #brgreen
    readonly FG_BASE00="\[$(tput setaf 11)\]" #bryellow
    readonly FG_BASE0="\[$(tput setaf 12)\]"  #brblue
    readonly FG_BASE1="\[$(tput setaf 14)\]"  #brcyan
    readonly FG_BASE2="\[$(tput setaf 7)\]"   #white
    readonly FG_BASE3="\[$(tput setaf 15)\]"  #brwhite

    readonly BG_BASE03="\[$(tput setab 8)\]"
    readonly BG_BASE02="\[$(tput setab 0)\]"
    readonly BG_BASE01="\[$(tput setab 10)\]"
    readonly BG_BASE00="\[$(tput setab 11)\]"
    readonly BG_BASE0="\[$(tput setab 12)\]"
    readonly BG_BASE1="\[$(tput setab 14)\]"
    readonly BG_BASE2="\[$(tput setab 7)\]"
    readonly BG_BASE3="\[$(tput setab 15)\]"

    readonly FG_YELLOW="\[$(tput setaf 3)\]"  #yellow
    readonly FG_ORANGE="\[$(tput setaf 9)\]"  #brred
    readonly FG_RED="\[$(tput setaf 1)\]"     #red
    readonly FG_MAGENTA="\[$(tput setaf 5)\]" #magenta
    readonly FG_VIOLET="\[$(tput setaf 13)\]" #brmagenta
    readonly FG_BLUE="\[$(tput setaf 4)\]"    #blue
    readonly FG_CYAN="\[$(tput setaf 6)\]"    #cyan
    readonly FG_GREEN="\[$(tput setaf 2)\]"   #green

    readonly BG_YELLOW="\[$(tput setab 3)\]"
    readonly BG_ORANGE="\[$(tput setab 9)\]"
    readonly BG_RED="\[$(tput setab 1)\]"
    readonly BG_MAGENTA="\[$(tput setab 5)\]"
    readonly BG_VIOLET="\[$(tput setab 13)\]"
    readonly BG_BLUE="\[$(tput setab 4)\]"
    readonly BG_CYAN="\[$(tput setab 6)\]"
    readonly BG_GREEN="\[$(tput setab 2)\]"

    readonly DIM="\[$(tput dim)\]"
    readonly REVERSE="\[$(tput rev)\]"
    readonly RESET="\[$(tput sgr0)\]"
    readonly BOLD="\[$(tput bold)\]"

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
            [ -n "$(git status --porcelain)" ] && marks+=" $GIT_BRANCH_CHANGED_SYMBOL"

            # how many commits local branch is ahead/behind of remote?
            local stat="$(git status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
            local aheadN="$(echo $stat | grep -o 'ahead \d\+' | grep -o '\d\+')"
            local behindN="$(echo $stat | grep -o 'behind \d\+' | grep -o '\d\+')"
            [ -n "$aheadN" ] && marks+=" $GIT_NEED_PUSH_SYMBOL$aheadN"
            [ -n "$behindN" ] && marks+=" $GIT_NEED_PULL_SYMBOL$behindN"

            # print the git branch segment without a trailing newline
            printf "$GIT_BRANCH_SYMBOL$branch$marks"
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
            local BG_EXIT="$BG_RED"
            local FG_EXIT="$FG_RED"
        else
            local BG_EXIT="$BG_GREEN"
            local FG_EXIT="$FG_GREEN"
        fi

        PS1=""

        # username
        if [[ $(whoami) == "root" ]]; then
          PS1+="$BG_RED$FG_BASE3 \u $RESET"
          PS1+="$BG_BASE00$FG_RED$PROMPT_DIVIDER$RESET"
        else
          PS1+="$BG_BLUE$FG_BASE3 \u $RESET"
          PS1+="$BG_BASE00$FG_BLUE$PROMPT_DIVIDER$RESET"
        fi

        # path
        # PS1+="$BG_BASE00$FG_BASE3 \w $RESET"
        PS1+="$BG_BASE00$FG_BASE3 $(__pwd) $RESET"

        # git status
        if (__is_git_branch); then
            PS1+="$BG_BASE01$FG_BASE00$PROMPT_DIVIDER$RESET"
            PS1+="$BG_BASE01$FG_BASE1 $(__git_info) $RESET"
            PS1+="$BG_EXIT$FG_BASE01$PROMPT_DIVIDER$RESET"
        else
            PS1+="$BG_EXIT$FG_BASE00$PROMPT_DIVIDER$RESET"
        fi
        # segment transition
        PS1+="$FG_EXIT$PROMPT_DIVIDER$RESET "
    }

    PROMPT_COMMAND=ps1
}

__powerline
unset __powerline
