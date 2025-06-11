#!/bin/sh
source "$PWD/config.l";
echo "config loaded";

if [[ $bar == "waybar" ]]; then
	ln -s $PWD/waybar ~/.config/waybar;
fi

if [[ $menu == "wofi" ]]; then
	ln -s $PWD/wofi ~/.config/wofi;
fi

if [[ $desktop == "hyprland" ]]; then
	ln -s $PWD/hypr ~/.config/hypr;
fi

if [[ $terminal == "kitty" ]]; then
	ln -s $PWD/kitty ~/.config/kitty;
fi

echo "link created";

if [[ $install_utils == "yes" ]]; then
	$installCMD git tmux wget curl;
	ln -s $PWD/tmux.conf ~/.tmux.conf
	echo "utils installed!";
fi


if [[ $install_nvim == "yes" ]]; then
	$installCMD neovim;
	git clone https://github.com/Lumetas/nvim-cfg.git nvim;
	ln -s $PWD/nvim ~/.config/nvim;
	echo "Do you want to install nvim dependencies? (press \"y\")";
	read -n 1 -r char;
	if [[ "$char" == "y" ]]; then
		$installCMD npm node rust-analyzer;
		npm i -g intelephense;
		echo "Dependencies installed!";
	fi
	echo "nvim installed!";
fi

if [[ $install_term_file_manager != "no" ]]; then
	$installCMD $install_term_file_manager;
	echo "terminal file manager installed!";
fi


$installCMD $dependencies && echo "dependencies installed!";

echo "installed !";
