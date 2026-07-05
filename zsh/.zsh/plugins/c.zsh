# Функция для работы с буфером обмена
# Использование:
#   c c          - скопировать stdin в буфер обмена
#   c p          - вставить из буфера обмена в stdout
c() {
    local action="$1"
    
    # Определяем ОС
    local os_type=""
    case "$(uname -s)" in
        Linux*)     os_type="linux";;
        Darwin*)    os_type="macos";;
        CYGWIN*|MINGW*|MSYS*) os_type="windows";;
        FreeBSD*)   os_type="freebsd";;
        *)          os_type="unknown";;
    esac
    
    # Функция для копирования
    copy_to_clipboard() {
        local data
        data=$(cat)
        
        case "$os_type" in
            linux)
                # Проверяем Wayland или X11
                if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy >/dev/null 2>&1; then
                    echo -n "$data" | wl-copy
                elif command -v xclip >/dev/null 2>&1; then
                    echo -n "$data" | xclip -selection clipboard
                elif command -v xsel >/dev/null 2>&1; then
                    echo -n "$data" | xsel --clipboard --input
                else
                    echo "Ошибка: установите wl-clipboard, xclip или xsel" >&2
                    return 1
                fi
                ;;
            macos)
                if command -v pbcopy >/dev/null 2>&1; then
                    echo -n "$data" | pbcopy
                else
                    echo "Ошибка: pbcopy не найден" >&2
                    return 1
                fi
                ;;
            windows)
                if command -v clip.exe >/dev/null 2>&1; then
                    echo -n "$data" | clip.exe
                elif command -v clip >/dev/null 2>&1; then
                    echo -n "$data" | clip
                else
                    echo "Ошибка: clip.exe не найден" >&2
                    return 1
                fi
                ;;
            freebsd)
                # FreeBSD может использовать xclip или свой paste/copy
                if command -v xclip >/dev/null 2>&1; then
                    echo -n "$data" | xclip -selection clipboard
                elif command -v paste >/dev/null 2>&1; then
                    # Для консольных сессий, где нет X11
                    echo -n "$data" > /tmp/clipboard_buffer
                    export CLIPBOARD_FILE="/tmp/clipboard_buffer"
                else
                    echo "Ошибка: нет инструментов для буфера обмена" >&2
                    return 1
                fi
                ;;
            *)
                echo "Ошибка: неподдерживаемая ОС" >&2
                return 1
                ;;
        esac
    }
    
    # Функция для вставки
    paste_from_clipboard() {
        case "$os_type" in
            linux)
                if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-paste >/dev/null 2>&1; then
                    wl-paste
                elif command -v xclip >/dev/null 2>&1; then
                    xclip -selection clipboard -o 2>/dev/null
                elif command -v xsel >/dev/null 2>&1; then
                    xsel --clipboard --output
                else
                    echo "Ошибка: установите wl-clipboard, xclip или xsel" >&2
                    return 1
                fi
                ;;
            macos)
                if command -v pbpaste >/dev/null 2>&1; then
                    pbpaste
                else
                    echo "Ошибка: pbpaste не найден" >&2
                    return 1
                fi
                ;;
            windows)
                if command -v powershell.exe >/dev/null 2>&1; then
                    powershell.exe -command "Get-Clipboard"
                else
                    echo "Ошибка: powershell.exe не найден" >&2
                    return 1
                fi
                ;;
            freebsd)
                if command -v xclip >/dev/null 2>&1; then
                    xclip -selection clipboard -o 2>/dev/null
                elif [[ -n "$CLIPBOARD_FILE" ]] && [[ -f "$CLIPBOARD_FILE" ]]; then
                    cat "$CLIPBOARD_FILE"
                else
                    echo "Ошибка: буфер обмена пуст или недоступен" >&2
                    return 1
                fi
                ;;
            *)
                echo "Ошибка: неподдерживаемая ОС" >&2
                return 1
                ;;
        esac
    }
    
    # Основная логика
    case "$action" in
        c)
            copy_to_clipboard
            ;;
        p)
            paste_from_clipboard
            ;;
        *)
            echo "Usage: c {c|p}" >&2
            echo "  c c  - copy stdin to clipboard" >&2
            echo "  c p  - paste from clipboard to stdout" >&2
            return 1
            ;;
    esac
}
