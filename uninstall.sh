#!/bin/sh
source $PWD/config.l
unlink ~/.config/waybar
unlink ~/.config/wofi
unlink ~/.config/hypr
unlink ~/.config/kitty

if [[ $install_nvim == "yes" ]]; then
    unlink ~/.config/nvim
fi

echo "uninstalled!";
