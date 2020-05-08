#!/bin/sh

# Script for installing tmux & htop on systems where you don't have root access.
# Inspired by https://gist.github.com/ryin/3106801
# tmux will be installed in $HOME/local/bin.
# htop will be installed in $HOME/local/bin.
# It's assumed that wget and a C/C++ compiler are installed.

# exit on error
set -e

TMUX_URL=https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz
HTOP_URL=https://hisham.hm/htop/releases/2.0.2/htop-2.0.2.tar.gz
LIBEVENT_URL=https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
NCURSES_URL=ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz

# create our directories
mkdir -p $HOME/local $HOME/tmux_htop_tmp
cd $HOME/tmux_htop_tmp

# download source files for tmux, libevent, and ncurses
wget $TMUX_URL -O tmux.tar.gz
wget $HTOP_URL -O htop.tar.gz
wget $LIBEVENT_URL -O libevent.tar.gz
wget $NCURSES_URL -O ncurses.tar.gz

# extract files, configure, and compile

############
# libevent #
############
mkdir -p $HOME/tmux_htop_tmp/libevent
tar xvzf libevent.tar.gz -C $HOME/tmux_htop_tmp/libevent --strip-components=1
cd libevent
./configure --prefix=$HOME/local --disable-shared
make
make install
cd ..

############
# ncurses  #
############
mkdir -p $HOME/tmux_htop_tmp/ncurses
tar xvzf ncurses.tar.gz -C $HOME/tmux_htop_tmp/ncurses --strip-components=1
cd ncurses
./configure --prefix=$HOME/local
make
make install
cd ..

############
# tmux     #
############
mkdir -p $HOME/tmux_htop_tmp/tmux
tar xvzf tmux.tar.gz -C $HOME/tmux_htop_tmp/tmux --strip-components=1
cd tmux
./configure CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"
CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make
cp tmux $HOME/local/bin
cd ..

############
# htop     #
############
mkdir -p $HOME/tmux_htop_tmp/htop
tar xvzf htop.tar.gz -C $HOME/tmux_htop_tmp/htop --strip-components=1
cd htop
./configure --disable-unicode CFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-L$HOME/local/lib -L$HOME/local/include/ncurses -L$HOME/local/include"
CPPFLAGS="-I$HOME/local/include -I$HOME/local/include/ncurses" LDFLAGS="-static -L$HOME/local/include -L$HOME/local/include/ncurses -L$HOME/local/lib" make
cp htop $HOME/local/bin
cd ..

# cleanup
rm -rf $HOME/tmux_htop_tmp

echo "$HOME/local/bin/tmux is now available. You can optionally add $HOME/local/bin to your PATH."
echo "$HOME/local/bin/htop is now available. You can optionally add $HOME/local/bin to your PATH."
