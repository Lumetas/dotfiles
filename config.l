# Данные об установке системы
desktop=hyprland
bar=waybar
menu=wofi
terminal=kitty
shell=zsh

# Список зависимостей
dependencies="hyprland hyprlock wofi kitty waybar zsh"

# Команда пакетного менеджера для установки, желательно без подтверждения
installCMD="sudo pacman -S --noconfirm"
# Для тестов, чтобы не устанавливать пакеты
# installCMD="echo"

# Блок необязательных установок
install_utils="yes"
install_nvim="yes"
install_term_file_manager="yazi" # "no" or "name"
