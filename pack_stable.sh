#!/bin/bash
set -e

# Author: He Zhenliang
# Date: 2023

rm -rf ./stable
mkdir ./stable


# vimrc
rm -rf ./stable/.vim_runtime
cp -r $HOME/.vim_runtime ./stable/.vim_runtime


# fzf
rm -rf ./stable/.fzf
cp -r $HOME/.fzf ./stable/.fzf


# lesspipe
cp $TOOL_HOME/bin/lesspipe.sh ./stable/lesspipe.sh


# oh-my-zsh
rm -rf ./stable/.oh-my-zsh
cp -r $HOME/.oh-my-zsh ./stable/.oh-my-zsh


# pack
tar cvzf stable.tar.gz stable
