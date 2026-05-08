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

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
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
export PATH="$PATH:$HOME/.config/composer/vendor/bin:/home/lum/.local/bin"
export TERM=xterm-256color
alias ls='ls --color=auto -h'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias rd='rmdir'
alias path='echo -e ${PATH//:/\\n}'
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp 2>/dev/null | grep LISTEN'
alias fucking='sudo $(fc -ln -1)'   # исправляет последнюю команду

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit -a -m'
alias gac='git add . && git commit'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gd='git diff'

if command -v batcat &> /dev/null; then
    alias cat='batcat'
elif command -v bat &> /dev/null; then
    alias cat='bat'
fi
setopt PROMPT_SUBST
autoload -U colors && colors
bindkey '^?' backward-delete-char

[ -f ~/.zsh_local ] && source ~/.zsh_local
source ~/.zsh/themes/agnoster.zsh-theme
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey -e
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

bindkey '^[OA' up-line-or-beginning-search
bindkey '^[OB' down-line-or-beginning-search


if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" = "1" ]]; then
	exec startx -- -keeptty
fi
