alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'


HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY          # timestamp + duration
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
export EDITOR=nvim
setopt HIST_IGNORE_SPACE          # команды с пробелом не в историю
HISTFILE=~/.zsh_history
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY         # моментальная запись

setopt AUTO_CD                    # cd в директорию просто по имени
setopt CORRECT                    # исправление опечаток
setopt EXTENDED_GLOB
setopt GLOB_DOTS                  # скрытые файлы в глобах
export LS_COLORS='fi=0:di=01;34:ex=01;32:ln=01;36:*.tar=01;31:*.zip=01;31'

autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zcompcache

setopt COMPLETE_IN_WORD

alias sc="sesh connect \$(sesh list | fzf)"
alias fport="ssh -R \"9090:localhost:6660\" lumetas.ru"
alias fep="/home/lum/fep/fep"
alias otdrestart="systemctl --user restart opentabletdriver"
alias tm="tmux attach -t main || tmux new -s main"
alias gpumine="__NV_PRIME_RENDER_OFFLOAD=1 flatpak run io.mrarm.mcpelauncher > /dev/null & watch nvidia-smi"
alias ls='lsd'
export PATH="$PATH:$HOME/.config/composer/vendor/bin:/home/lum/.local/bin:/home/lum/.opencode/bin"
export TERM=xterm-256color
alias ez='nvim ~/.zshrc'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias rd='rmdir'
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl -s 2ip.ru'
alias ports='__get_ports__'
alias fuck='sudo $(fc -ln -1)'   # исправляет последнюю команду

alias md='inlyne -t dark'

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a -m'
alias gac='git add . && git commit'
alias gP='git push'
alias gp='git pull'
alias gl='git log --oneline --graph'
alias gd='git diff'
alias gm='git merge'

if command -v batcat &> /dev/null; then
    alias cat='batcat'
elif command -v bat &> /dev/null; then
    alias cat='bat'
fi

function __get_ports__() {
	if [[ "$1" == "-a" ]]; then
		ss -tulpn 2>/dev/null | awk 'NR>1 {split($5,a,":"); port=a[length(a)]; pid=gensub(/.*pid=([0-9]+),.*/,"\\1","g",$7); proc=gensub(/.*users:\(\("([^"]+)".*/,"\\1","g",$7); printf "%-8s %-8s %s\n", port, (pid~/^[0-9]+$/ ? pid : "N/A"), (proc?proc:"N/A")}' | sort -n | uniq
	elif [[ "$1" == "-j" ]]; then
		ss -tulpn 2>/dev/null | awk 'NR>1 {split($5,a,":"); port=a[length(a)]; pid=gensub(/.*pid=([0-9]+),.*/,"\\1","g",$7); proc=gensub(/.*users:\(\("([^"]+)".*/,"\\1","g",$7); if(proc!="") print "{\"port\":"port",\"pid\":"(pid~/[0-9]+/?pid:"null")",\"process\":\""proc"\"}"}' | sort -n | uniq | jq -s '.'
	else
		ss -tulpn 2>/dev/null | awk 'NR>1 {split($5,a,":"); print a[length(a)]}' | sort -n | uniq
	fi
}
setopt PROMPT_SUBST
autoload -U colors && colors
bindkey '^?' backward-delete-char

[ -f ~/.zsh_local ] && source ~/.zsh_local
source ~/.zsh/themes/agnoster.zsh-theme
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]='fg=white'
ZSH_HIGHLIGHT_STYLES[alias]='fg=white'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=white'

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -e
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search


# if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" = "1" ]]; then
# 	exec startx -- -keeptty
# fi
