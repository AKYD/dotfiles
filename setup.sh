#!/bin/bash

rm -f ~/.bashrc ~/.tmux.conf ~/.vimrc

cd

ln -s dotfiles/bashrc ~/.bashrc
ln -s dotfiles/tmux.conf ~/.tmux.conf
ln -s .vim/vimrc ~/.vimrc

. ~/.bashrc
