#!/bin/bash

source "./rank.sh"
OUTPUT=$(rank "$HOME/.ssh/config" "(?<=^Host )(?!\*).+" "$HOME/.ssh/rank")

# print is a zsh built-in command, not working in bash
# https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html
print -z "ssh $OUTPUT"