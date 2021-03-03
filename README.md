# bash-powerline

Powerline for Bash in pure Bash script. 

<!-- ![bash-powerline](https://raw.github.com/fcastilloec/bash-powerline/master/screenshots/solarized-light.png) -->
<!-- ![bash-powerline](https://raw.github.com/fcastilloec/bash-powerline/master/screenshots/solarized-dark.png) -->

## Features

* Git branch: display current git branch name, or short SHA1 hash when the head
  is detached
* Git branch: display "+" symbol when current branch is changed but uncommitted
* Git branch: display "⇡" symbol and the difference in the number of commits when the current branch is ahead of remote (see screenshot)
* Git branch: display "⇣" symbol and the difference in the number of commits when the current branch is behind of remote (see screenshot)
* Color code for the previously failed command
* Fast execution (no noticeable delay)
* No need for patched fonts (but works better with them)
* Can configure the character used for directory separator
* Can configure the maximum directory length to display


## Installation

Download the Bash script

    curl https://raw.github.com/fcastilloec/bash-powerline/master/bash-powerline.sh > ~/.bash-powerline.sh

And source it in your `.bashrc`

    source ~/.bash-powerline.sh

For best result, use [Solarized
colorscheme](https://github.com/altercation/solarized) for your terminal
emulator. Or hack your own colorscheme by modifying the script. It's really
easy.


## Why?

This script is largely inspired by
[powerline-shell](https://github.com/milkbikis/powerline-shell). The biggest
problem is that it is implemented in Python. Python scripts are much easier to
write and maintain than Bash scripts, but for my simple cases I find Bash
scripts to be manageable. However, invoking the Python interpreter each time to
draw the shell prompt introduces a noticeable delay. I hate delays. So I decided
to port just the functionalities I need to pure Bash script instead. 

The other issue is that I don't like the idea of requiring patched fonts for
this to work. The font patching mechanism from the original Powerline does not
work with the bitmap font (Apple Monaco without anti-aliasing) I use on
non-retina screens. I'd rather stick with existing unicode symbols in the fonts.
