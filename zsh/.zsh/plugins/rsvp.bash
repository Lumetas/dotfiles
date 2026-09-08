#!/bin/env bash
set -u
WPM=${WPM:-250}
RESUME=0
PAUSED=0
WORD_COUNTER=0
LETTER_COUNTER=0
SKIPPED=0
CONTEXT_PRINTED=0
CURRENT_WORD=""
CURRENT_ORP=0
SCRIPT=0
NEXT_WORD_TIME=0
START_TIME=0
RUNNING=1
CONTEXT_WORDS=${CONTEXT_WORDS:-15}

ORP_VISUAL_POS=20
CURSOR_POS=64

WORD_TIME=0.9
LEN_TIME=0.04
COMMA_TIME=2
FSTOP_TIME=3
MULTI_TIME=1.2
FIRST_TIME=0.2

while [[ $# -gt 0 ]]; do
    case "$1" in
        -w|--wpm)   WPM="$2";    shift 2 ;;
        -r|--resume) RESUME="$2"; shift 2 ;;
		-c|--context) CONTEXT_WORDS="$2"; shift 2 ;;
		-s|--script) SCRIPT="$2"; shift 2 ;;
		*) echo "Usage: $0 [-w WPM] [-r RESUME] [-c CONTEXT] [-s SCRIPT(1|0)] < file.txt"; exit 1 ;;
    esac
done

if ! command -v bc &>/dev/null; then
    echo "Error 'bc' not found, please install" >&2
    exit 1
fi

TEXT=$(cat)
WORDS=()
while IFS= read -r w; do
    [[ -n "$w" ]] && WORDS+=("$w")
done < <(echo "$TEXT" | sed 's/[-,.;:!?]/ /g' | tr -s ' ' '\n')

if [[ ${#WORDS[@]} -eq 0 ]]; then
    echo "No words"
    exit 1
fi

setup_terminal() {
    OLD_STTY=$(stty -g 2>/dev/null || true)
    stty -echo -icanon min 1 time 0 2>/dev/null || true
    tput civis 2>/dev/null || true
    tput clear 2>/dev/null || true
    exec < /dev/tty
}

restore_terminal() {
    stty "$OLD_STTY" 2>/dev/null || stty echo icanon 2>/dev/null || true
    tput cnorm 2>/dev/null || true
}

find_orp() {
    local len=${#1}
    if (( len > 13 )); then
        echo 4
    else
        case $len in
            0|1) echo 0 ;;
            2|3|4|5) echo 1 ;;
            6|7|8|9) echo 2 ;;
            10|11|12|13) echo 3 ;;
            *) echo 0 ;;
        esac
    fi
}

get_context() {
    # Используем IDX для определения реальной позиции в массиве
    local idx=$IDX
    if [[ $idx -le 0 ]]; then
        echo ""
        return
    fi
    
    # Берем до 15 слов перед текущим
    local start=$((idx - CONTEXT_WORDS))
    (( start < 0 )) && start=0
    
    local context=""
    for ((i=start; i<idx; i++)); do
        context="$context ${WORDS[$i]}"
    done
    
    # Убираем первый пробел
    context="${context# }"
    echo "$context"
}

show_word() {
    local word="$1" orp="$2"
    local prefix="${word:0:$orp}"
    local pivot="${word:$orp:1}"
    local suffix="${word:$((orp+1))}"
    [[ "$pivot" == " " ]] && pivot="·"

    local pad_left=$((ORP_VISUAL_POS - orp))
    (( pad_left < 0 )) && pad_left=0
    local word_len=${#word}
    local pad_right=$((CURSOR_POS - pad_left - word_len))
    (( pad_right < 0 )) && pad_right=0

    if (( PAUSED == 1 )); then
        if (( CONTEXT_PRINTED == 1 )); then return; fi
        tput clear 2>/dev/null || true
        echo -e "\033[33m=== PAUSED ===\033[0m"
        
        local context=$(get_context)
        if [[ -n "$context" ]]; then
            # Подсвечиваем последнее слово (текущее) жёлтым
            # Находим последнее слово в контексте
            local last_word="${context##* }"
            if [[ -n "$last_word" ]]; then
                # Заменяем последнее слово на жёлтое
                context="${context% $last_word}"
                echo -e "\033[90m${context} \033[33m${last_word}\033[0m"
            else
                echo -e "\033[90m$context\033[0m"
            fi
        else
            echo -e "\033[90m(начало текста)\033[0m"
        fi
        echo ""
        printf "\033[1m%s\033[31m%s\033[0m\033[1m%s\033[0m\n" "$prefix" "$pivot" "$suffix"
        echo -e "\033[90mWPM: $WPM | Слово: $WORD_COUNTER/${#WORDS[@]}\033[0m"
        CONTEXT_PRINTED=1
    else
        printf "\r\033[K%${pad_left}s\033[1m%s\033[31m%s\033[0m\033[1m%s" \
               "" "$prefix" "$pivot" "$suffix" #"" "$WPM"
    fi
}

show_guide() {
    printf "\r%${ORP_VISUAL_POS}s\033[31mv\033[0m\033[K\n" ""
}

word_time() {
    local word="$1"
    local time=$WORD_TIME
    local len=${#word}

    local last="${word: -1}"
    if [[ "$last" == "." ]] || [[ "$last" == "?" ]] || [[ "$last" == "!" ]]; then
        time=$FSTOP_TIME
    elif [[ "$last" == ":" ]] || [[ "$last" == ";" ]] || [[ "$last" == "," ]]; then
        time=$COMMA_TIME
    elif [[ "$word" == *" "* ]]; then
        time=$MULTI_TIME
    fi

    time=$(echo "$time + sqrt($len) * $LEN_TIME" | bc -l 2>/dev/null)
    time=$(echo "$time * 60 / $WPM" | bc -l 2>/dev/null)
    if (( WORD_COUNTER == 0 )); then
        local first_ok=$(echo "$time < $FIRST_TIME" | bc -l 2>/dev/null)
        [[ "$first_ok" == "1" ]] && time=$FIRST_TIME
    fi
    echo "$time"
}

speed_down() {
    WPM=$((WPM * 90 / 100))
    (( WPM < 1 )) && WPM=1
    if [[ -n "$CURRENT_WORD" ]]; then
        local now=$(date +%s.%N 2>/dev/null || date +%s)
        local wtime=$(word_time "$CURRENT_WORD")
        NEXT_WORD_TIME=$(echo "$now + $wtime" | bc -l 2>/dev/null)
    fi
}

speed_up() {
    WPM=$((WPM * 110 / 100))
    (( WPM < 1 )) && WPM=1
    if [[ -n "$CURRENT_WORD" ]]; then
        local now=$(date +%s.%N 2>/dev/null || date +%s)
        local wtime=$(word_time "$CURRENT_WORD")
        NEXT_WORD_TIME=$(echo "$now + $wtime" | bc -l 2>/dev/null)
    fi
}

toggle_pause() {
    if (( PAUSED == 0 )); then
        PAUSED=1
        show_word "$CURRENT_WORD" "$CURRENT_ORP"
    else
        PAUSED=0
        CONTEXT_PRINTED=0
        tput clear 2>/dev/null || true
        show_guide
        local now=$(date +%s.%N 2>/dev/null || date +%s)
        if [[ -n "$CURRENT_WORD" ]]; then
            local wtime=$(word_time "$CURRENT_WORD")
            NEXT_WORD_TIME=$(echo "$now + $wtime" | bc -l 2>/dev/null)
        else
            NEXT_WORD_TIME="$now"
        fi
    fi
}

print_stats() {
	return
	if (( SCRIPT == 1 )); then return; fi
    local now=$(date +%s.%N 2>/dev/null || date +%s)
    local elapsed=$(echo "$now - $START_TIME" | bc -l 2>/dev/null)
    [[ -z "$elapsed" || "$elapsed" == "0" ]] && elapsed=1
    local truewpm=$(echo "$WORD_COUNTER / $elapsed * 60" | bc -l 2>/dev/null | awk '{printf "%.2f", $0}')
    printf "\n%.2fs, %d words, %d letters, \033[1;32m%s\033[0m true wpm\n" \
           "$elapsed" "$WORD_COUNTER" "$LETTER_COUNTER" "$truewpm"
}

cleanup() {
    RUNNING=0
    trap '' SIGINT SIGTERM SIGTSTP SIGQUIT
    restore_terminal
    print_stats
    local resume_word=$((WORD_COUNTER + RESUME))
	echo;
	if (( SCRIPT == 1 )); then
		echo -n $resume_word >&2;
	else
		echo -n "To resume from this point run with argument -r $resume_word"
	fi
    exit 0
}

setup_signals() {
    trap 'toggle_pause' SIGQUIT
    trap 'cleanup' EXIT
    trap '' SIGPIPE
}

setup_signals
setup_terminal
show_guide

START_TIME=$(date +%s.%N 2>/dev/null || date +%s)
NEXT_WORD_TIME="$START_TIME"

IDX=0
while (( IDX < ${#WORDS[@]} )) && (( RUNNING == 1 )); do
    if (( SKIPPED < RESUME )); then
        ((SKIPPED++))
        ((IDX++))
        continue
    fi

    NOW=$(date +%s.%N 2>/dev/null || date +%s)

    if (( PAUSED == 0 )); then
        time_ready=$(echo "$NOW >= $NEXT_WORD_TIME" | bc -l 2>/dev/null)
        if [[ "$time_ready" == "1" ]]; then
            CURRENT_WORD="${WORDS[$IDX]}"
            CURRENT_ORP=$(find_orp "$CURRENT_WORD")
            WTIME=$(word_time "$CURRENT_WORD")
            NEXT_WORD_TIME=$(echo "$NOW + $WTIME" | bc -l 2>/dev/null)
            ((WORD_COUNTER++))
            LETTER_COUNTER=$((LETTER_COUNTER + ${#CURRENT_WORD}))
            ((IDX++))
        fi
    fi

    show_word "$CURRENT_WORD" "$CURRENT_ORP"
    sleep 0.01
done

cleanup
