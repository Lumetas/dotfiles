if status is-interactive
	alias lser="~/LumProjects/lser/lser"
	alias emfymount="curlftpfs p.teplyakov:kQnPK904McfJB15K@80.249.151.42/"
	alias pacman="sudo pacman";
	alias sc="sesh connect \$(sesh list | fzf)"
	alias fport="ssh -R \"9090:localhost:6660\" lumetas.ru"
	alias open='xdg-open'
	# ___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi
	export TERM=xterm-256color
	alias fep="/home/lum/fep/fep"
	alias otdrestart="systemctl --user restart opentabletdriver"
	eval $(fzf --fish)
	alias ls=lsd
	alias gpumine="__NV_PRIME_RENDER_OFFLOAD=1 flatpak run io.mrarm.mcpelauncher > /dev/null & watch nvidia-smi"
	alias l="ls -la"
	alias n="nvim-test"
	alias nvim-test='NVIM_APPNAME="nvim-test" nvim'
	alias lazyvim='NVIM_APPNAME="lazyvim" nvim'
	alias lazyvide='NVIM_APPNAME="lazyvim" nvide'
	export PATH="$PATH:$HOME/.config/composer/vendor/bin:/home/lum/.local/bin"
	export EDITOR=nvim
	set -U fish_greeting
	source ~/.config/fish/fprompt.fish
end
