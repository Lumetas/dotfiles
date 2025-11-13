# Данные об установке системы
desktop=hyprland
bar=waybar
menu=wofi
terminal=kitty
// shell=fish

# Список зависимостей
dependencies="hyprland hyprlock wofi kitty waybar zsh"

# Команда пакетного менеджера для установки, желательно без подтверждения
// installCMD="sudo dnf install -y"
# Для тестов, чтобы не устанавливать пакеты
 installCMD="echo"

# Блок необязательных установок
install_utils="yes"
install_nvim="no"
install_term_file_manager="yazi" # "no" or "name"
