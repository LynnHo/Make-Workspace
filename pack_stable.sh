#!/bin/bash
set -e

# Author: He Zhenliang
# Date: 2023

mkdir ./stable

# vimrc
rm -rf ./stable/.vim_runtime
cp -r $HOME/.vim_runtime ./stable/.vim_runtime

# fzf
rm -rf ./stable/.fzf
cp -r $HOME/.fzf ./stable/.fzf
cp $TOOL_HOME/bin/fzf ./stable/fzf

# lesspipe
cp $TOOL_HOME/bin/lesspipe.sh ./stable/lesspipe.sh

# oh-my-zsh
rm -rf ./stable/.oh-my-zsh
cp -r $HOME/.oh-my-zsh ./stable/.oh-my-zsh

# pack
tar cvzf stable.tar.gz stable

rm -rf ./stable

# make tools_stable.yml
echo 'name: tools
channels:
  - conda-forge
dependencies:' > tools_stable.yml

packages=($(grep 'dependencies' tools.yml -A 10000 | grep -E '^[ ]*-' | sed 's/[ ]*\-[ ]*\([^ =#]*\).*/\1/g'))
versions=$(conda env export -n tools --no-builds)
for package in "${packages[@]}"; do
  echo "$versions" | grep "\- $package="
done >> tools_stable.yml
