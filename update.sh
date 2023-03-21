#!/bin/bash

rm .zshenv
cp ~/.zshenv .

rm .tmux.conf
cp ~/.tmux.conf .

rm -r .config

mkdir -p .config/alacritty
cp ~/.config/alacritty/alacritty.yml .config/alacritty

mkdir -p .config/zsh
cp ~/.config/zsh/.start .config/zsh
cp ~/.config/zsh/.zshrc .config/zsh

mkdir -p .config/nvim
cp -r ~/.config/nvim/lua .config/nvim/lua
cp -r ~/.config/nvim/syntax .config/nvim/syntax
cp ~/.config/nvim/legacy.vim .config/nvim
cp ~/.config/nvim/init.lua .config/nvim
