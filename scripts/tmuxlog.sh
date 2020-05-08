#!/bin/sh

# Script for following up *.result files of assembly calculations

session="long"

# set up tmux
tmux start-server

# check if the session exists, discarding output
# we can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]; then

  tmux set pane-border-status bottom

  # create a new tmux session
  tmux new-session -d -s $session

  # select pane 0 and split horizontally by 50%
  tmux selectp -t 0
  tmux splitw -h -p 50

  # select pane 1 and split vertically by 50%
  tmux selectp -t 1
  tmux splitw -v -p 50

  # select pane 0 and split vertically by 50%
  tmux selectp -t 0
  tmux splitw -v -p 50

  tmux selectp -t 0 -T "ASSEMBLY_A"
  tmux send-keys "tail -f /tmp/ASSEMBLY_A/output*/*.result" C-m
  tmux selectp -t 1 -T "ASSEMBLY_B"
  tmux send-keys "tail -f /tmp/ASSEMBLY_B/output*/*.result" C-m
  tmux selectp -t 2 -T "ASSEMBLY_C"
  tmux send-keys "tail -f /tmp/ASSEMBLY_C/output*/*.result" C-m
  tmux selectp -t 3 -T "ASSEMBLY_D"
  tmux send-keys "tail -f /tmp/ASSEMBLY_D/output*/*.result" C-m
  # return to main window
  tmux selectp -t 0
  tmux select-window -t $session:0

fi

# finished setup, attach to the tmux session
tmux attach-session -t $session
