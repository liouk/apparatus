#!/bin/bash

Y='\033[1;33m'  # yellow - headers
C='\033[1;36m'  # cyan - keys
D='\033[0;37m'  # dim - descriptions
B='\033[1;35m'  # magenta - active tab
N='\033[0m'     # reset

fmt_entry() {
    local key="$1" desc="$2"
    local key_plain=$(printf "%b" "$key" | sed 's/\x1b\[[0-9;]*m//g')
    local pad=$(( 14 - ${#key_plain} ))
    (( pad < 1 )) && pad=1
    printf "%b%*s%b" "$key" "$pad" "" "$desc"
}

draw() {
    local page=$1
    local cols=$(tput cols)
    local col_w=$(( cols / 2 ))

    clear

    # tab bar
    local tabs=("1:General" "2:Windows" "3:Workspaces" "4:Other" "0:Bash")
    local bar=""
    local page_nums=(1 2 3 4 0)
    for i in "${!tabs[@]}"; do
        if (( page_nums[i] == page )); then
            bar+="${B}[ ${tabs[$i]} ]${N}  "
        else
            bar+="${D}  ${tabs[$i]}  ${N}  "
        fi
    done
    printf "\n  %b\n\n" "$bar"

    local -a left=() right=()
    case $page in
    1)
        left=(
            "${Y}APPS${N}"
            "$(fmt_entry "${C}Mod+Return${N}" "${D}terminal${N}")"
            "$(fmt_entry "${C}Mod+Space${N}" "${D}launcher${N}")"
            "$(fmt_entry "${C}Mod+p${N}" "${D}zed-picker${N}")"
            "$(fmt_entry "${C}Mod+t${N}" "${D}goot${N}")"
            "$(fmt_entry "${C}Mod+s${N}" "${D}skratch${N}")"
            "$(fmt_entry "${C}Mod+g${N}" "${D}glone${N}")"
            "$(fmt_entry "${C}Mod+,${N}" "${D}apparatus${N}")"
        )
        right=(
            "${Y}SESSION${N}"
            "$(fmt_entry "${C}Mod+Shift+c${N}" "${D}reload config${N}")"
            "$(fmt_entry "${C}Mod+Shift+e${N}" "${D}exit sway${N}")"
            "$(fmt_entry "${C}Mod+End${N}" "${D}lock screen${N}")"
            "$(fmt_entry "${C}Mod+Shift+q${N}" "${D}kill window${N}")"
            "$(fmt_entry "${C}Mod+/${N}" "${D}show shortcuts${N}")"
            ""
            "${Y}KEYBOARD${N}"
            "$(fmt_entry "${C}Super+Space${N}" "${D}next language${N}")"
        ) ;;
    2)
        left=(
            "${Y}FOCUS${N}"
            "$(fmt_entry "${C}Mod+h/j/k/l${N}" "${D}focus l/d/u/r${N}")"
            "$(fmt_entry "${C}Mod+a${N}" "${D}focus parent${N}")"
            ""
            "${Y}MOVE${N}"
            "$(fmt_entry "${C}Mod+Shift+h/j/k/l${N}" "${D}move window${N}")"
        )
        right=(
            "${Y}LAYOUT${N}"
            "$(fmt_entry "${C}Mod+b${N}" "${D}split horizontal${N}")"
            "$(fmt_entry "${C}Mod+v${N}" "${D}split vertical${N}")"
            "$(fmt_entry "${C}Mod+w${N}" "${D}tabbed layout${N}")"
            "$(fmt_entry "${C}Mod+e${N}" "${D}toggle split${N}")"
            "$(fmt_entry "${C}Mod+f${N}" "${D}fullscreen${N}")"
            "$(fmt_entry "${C}Mod+Shift+Space${N}" "${D}toggle floating${N}")"
            "$(fmt_entry "${C}Mod+r${N}" "${D}resize mode${N}")"
            "$(fmt_entry "${C}Mod+o${N}" "${D}toggle waybar${N}")"
        ) ;;
    3)
        left=(
            "${Y}SWITCH${N}"
            "$(fmt_entry "${C}Mod+1..9${N}" "${D}go to workspace${N}")"
            "$(fmt_entry "${C}Mod+Ctrl+h/l${N}" "${D}prev/next on output${N}")"
            "$(fmt_entry "${C}Mod+n${N}" "${D}new workspace${N}")"
        )
        right=(
            "${Y}MOVE CONTAINER${N}"
            "$(fmt_entry "${C}Mod+Shift+1..9${N}" "${D}send to workspace${N}")"
            ""
            "${Y}MOVE WORKSPACE${N}"
            "$(fmt_entry "${C}Mod+Ctrl+Shift+hjkl${N}" "${D}to other output${N}")"
        ) ;;
    4)
        left=(
            "${Y}SCRATCHPAD${N}"
            "$(fmt_entry "${C}Mod+0${N}" "${D}show scratchpad${N}")"
            "$(fmt_entry "${C}Mod+Shift+0${N}" "${D}send to scratchpad${N}")"
            "$(fmt_entry "${C}Mod+-${N}" "${D}scratch terminal${N}")"
            "$(fmt_entry "${C}Mod+=${N}" "${D}spotify${N}")"
        )
        right=(
            "${Y}SCREENSHOTS${N}"
            "$(fmt_entry "${C}Mod+Ctrl+3${N}" "${D}screenshot to file${N}")"
            "$(fmt_entry "${C}Mod+Ctrl+4${N}" "${D}screenshot to clip${N}")"
        ) ;;
    0)
        left=(
            "${Y}GENERAL${N}"
            "$(fmt_entry "${C}zed, z${N}" "${D}zeditor${N}")"
            "$(fmt_entry "${C}..${N}" "${D}cd ..${N}")"
            "$(fmt_entry "${C}...${N}" "${D}cd ../../${N}")"
            "$(fmt_entry "${C}icat${N}" "${D}kitty image viewer${N}")"
            ""
            "${Y}GIT${N}"
            "$(fmt_entry "${C}vimod${N}" "${D}vim modified files${N}")"
            "$(fmt_entry "${C}tiga${N}" "${D}tig --all${N}")"
            "$(fmt_entry "${C}gh-pr${N}" "${D}checkout PR${N}")"
            "$(fmt_entry "${C}gh-sync${N}" "${D}sync fork branch${N}")"
            "$(fmt_entry "${C}git-wt${N}" "${D}manage git worktrees${N}")"
            "$(fmt_entry "${C}git-wt rm${N}" "${D}remove a worktree${N}")"
            "$(fmt_entry "${C}gh-prw <n>${N}" "${D}PR in worktree${N}")"
        )
        right=(
            "${Y}DOCKER${N}"
            "$(fmt_entry "${C}doc${N}" "${D}docker compose${N}")"
            "$(fmt_entry "${C}dex${N}" "${D}docker exec -it${N}")"
            ""
            "${Y}K8S${N}"
            "$(fmt_entry "${C}kc${N}" "${D}kubectl${N}")"
            "$(fmt_entry "${C}kcs${N}" "${D}kubectl -n kube-system${N}")"
            "$(fmt_entry "${C}kns${N}" "${D}pick kube namespace${N}")"
        ) ;;
    esac

    local rows=$(( ${#left[@]} > ${#right[@]} ? ${#left[@]} : ${#right[@]} ))
    for (( i = 0; i < rows; i++ )); do
        local l="${left[$i]}"
        local r="${right[$i]}"
        local l_plain=$(printf "%b" "$l" | sed 's/\x1b\[[0-9;]*m//g')
        local pad=$(( col_w - ${#l_plain} ))
        (( pad < 1 )) && pad=1
        printf "  %b%*s%b\n" "$l" "$pad" "" "$r"
    done

    printf "\n  ${D}press 1-4/0 to switch, q to quit${N}\n"
}

page=1
draw $page

while true; do
    read -rsn1 key
    case "$key" in
        0|1|2|3|4) page=$key; draw $page ;;
        q|Q) break ;;
    esac
done

clear
