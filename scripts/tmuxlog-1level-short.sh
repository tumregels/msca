#!/bin/sh

# Script for following up *.result files of short assembly calculations

session="1level-short"

# set up tmux
tmux start-server

# check if the session exists, discarding output
# we can check $? for the exit status (zero for success, non-zero for failure)
tmux has-session -t $session 2>/dev/null

if [ $? != 0 ]; then
  # create a new tmux session
  tmux new-session -d -s $session

  # view pane titles at the top
  tmux set pane-border-status top
  tmux set pane-border-format ' #{pane_index} #{pane_title} '

  # select pane 0 and split horizontally by 50%
  tmux selectp -t 0
  tmux splitw -h -p 50

  # select pane 1 and split vertically by 50%
  tmux selectp -t 1
  tmux splitw -v -p 50

  # select pane 0 and split vertically by 50%
  tmux selectp -t 0
  tmux splitw -v -p 50

  tmux selectp -t 0 -T "A_1L_SHORT"
  tmux send-keys "cd /tmp/1L_SHORT/ASSBLY_A && ~/bin/runner/dist/run | grep '+++'" C-m
  tmux selectp -t 1 -T "B_1L_SHORT"
  tmux send-keys "cd /tmp/1L_SHORT/ASSBLY_B && ~/bin/runner/dist/run | grep '+++'" C-m
  tmux selectp -t 2 -T "C_1L_SHORT"
  tmux send-keys "cd /tmp/1L_SHORT/ASSBLY_C && ~/bin/runner/dist/run | grep '+++'" C-m
  tmux selectp -t 3 -T "D_1L_SHORT"
  tmux send-keys "cd /tmp/1L_SHORT/ASSBLY_D && ~/bin/runner/dist/run | grep '+++'" C-m
  # return to main window
  tmux selectp -t 0
  tmux select-window -t $session:0

fi

# finished setup, attach to the tmux session
tmux attach-session -t $session
