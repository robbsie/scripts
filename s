#!/bin/bash

SSH_OPTIONS="1246AaCfgKkMNnqsTtVvXxYyb:c:D:e:F:I:i:L:l:m:O:o:p:R:S:W:w:"

# We only care if we are in a terminal
tty -s || { ssh $@; exit; }

# We also only care if we are in screen which we infer by $TERM starting
# with "screen"
[ "${TERM:0:6}" != "screen" ] && { ssh $@; exit; }

# Get rid of all the ssh options and go to the hostname
while getopts "$SSH_OPTIONS" OPTION; do :; done
args="$@"
shift $((OPTIND-1)); OPTIND=1
HOST=$1

# get rid of the domain
if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]
then
  tmux set-option -g allow-rename off
  echo $HOST | tmux rename-window $HOST 
else
  echo $HOST | printf "\033k%s\033\\" $HOST
fi

# connect
ssh -v $args

# restore the name to the hostname of the local machine
if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]
then 
  # re-allow renaming of windows and set "bash" for name
  tmux rename-window bash
else
  hostname | printf "\033k%s\033\\" $(hostname) 
fi
