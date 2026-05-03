#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Gh0stD0rk Killer - Bash Edition
# Created by: The_Gh0stface_Killer
# For ethical hackers, OSINT investigators, security researchers.
# ─────────────────────────────────────────────────────────────

set -euo pipefail

SETTINGS_FILE="$HOME/.gdk_settings"
DORKS_FILE="saved_dorks.txt"
BOX_WIDTH=91

# ── Defaults ──────────────────────────────────────────────────
DEFAULT_ENGINE="Google"
AUTO_SAVE="false"
OUTPUT_FORMAT="plain"   # plain | url | json
SHODAN_API_KEY=""

load_settings() {
    [[ -f "$SETTINGS_FILE" ]] && source "$SETTINGS_FILE"
}

save_settings() {
    cat > "$SETTINGS_FILE" <<EOF
DEFAULT_ENGINE="$DEFAULT_ENGINE"
AUTO_SAVE="$AUTO_SAVE"
OUTPUT_FORMAT="$OUTPUT_FORMAT"
SHODAN_API_KEY="$SHODAN_API_KEY"
EOF
}

load_settings

# ── Display helpers ───────────────────────────────────────────
box() {
    local text="$1"
    local line
    printf "\n+%${BOX_WIDTH}s+\n" | tr ' ' '-'
    while IFS= read -r line; do
        printf "| %-${BOX_WIDTH}s |\n" "$line"
    done <<< "$text"
    printf "+%${BOX_WIDTH}s+\n\n" | tr ' ' '-'
}

banner() {
    local box_w=97
    local -a logo=(
    "                                                                                               "
    "                                       ==;    .-+:                                             "
    "                           ::..  .--;;.=#**-;+***.:;;-;  ...:.                                 "
    "                           ;***+++*%%###****#****###%#++++**=.                                 "
    "                     :;;;---=*+**+=+-::-:.;: -..;;:;=+++*+**----;;;.                           "
    "                 ..:;=*#*+***+=-;  .  ...: :. .: .  .  :-=+***++##+-::.                        "
    "              .-*****+++**++=;:  ..:;::+-+++*-*-=-.;;..  .:;+++**+++****+;                     "
    "   .:        .;=*+=++**=;:   .:;--: ;+-+@#%%%%%%*;+=..;--:.   .;-+**+++*=;:        .:          "
    "   ;%*******###*++*+=:     .:::::;*+-+@%%%%%%%%%%@#==*=:::::.     .-+**++*##*******#*          "
    "   ;@#*****##%@%#=:          .;=+=-#@%#**#*=++#***#%#+-++-:          .;*%@%###****#%*          "
    "   .%@%%#*++++#@@++**=:         ;*%*++##%+:==:;#%#***#%=.        .-+*+=%@#*++++*%%%@-          "
    "    ;%@%+*%#+++*++**#@@+---;     .=: +%@@:;@@* *@%#=;=;     :---=%@%#**+*+++*%#+#@@+           "
    "     :#%*+++++***%#++*#**##%%-::..+#+;;;;: .. .;::;=**:.:::*%%#***#++#%#**+++++*%%=            "
    "       #%####%%%#%#+++*##*+*##*##%*+%%#*+=+=-=++*#%%#+%##*#%*++##*+++*#%%%%####%%;             "
    "       *++#*:-%%##**#%%%%#+++*#*++#*:=+@=*+*@=%-%*+:=#++*#*+++*#%%%#***#%@+:-#*+#-             "
    "      .#+=*-  :+#%@@%###****##%#++#*  -+:;;-=:-:-=. ;%++*####****#%%@@@%*;   #++*=             "
    "      ;#++#-      ::.=+#%%#*###**+;:-;:.::;:.;::..:-;:=*####**%%#*=;::.      *+++*             "
    "     .*+++#-     .: ;:  .;;:;;::     .;::..--:.::;:     .:;;::::   =  :      #+++*-            "
    "     +*+++*+     ;- =.  +%%%%##*=-.      ..;+ :       :-+*#%%%#*:  =..-     :#++++#;           "
    "      ;**++#.     ;.:-  %@@@@@@@@@%*;     .:.:      =#@@@@@@@@@@- .= ;:     +*++*=.            "
    "     :**+++*+      . ;;  +@@@%%%%%%@+      :;      .@@%%%%%@@@%; .=.       :#+++**=            "
    "      :+#+++*-        :-: :+#@@@@@%+  ............  ;#@@@@@%*-. ;;        .*+++**-             "
    "    .=+++++++#:         :;:. .;--;.    :::.....::.    :;-;:...::.         :*+++++++;           "
    "    .=**++++*=                     .:.    .:::.   ..:.                     =*+++***;           "
    "       :+#++#                     =****+==+++++==*****:                    .#+*#-.             "
    "       =**=#-                 .;  .-+*==**++++**+=++=:  ::                  **+**;             "
    "       :-++#.             .::::     .;;..:;==-;. :-:     .::::          .*. =#+=;.             "
    "         :*#            ..            .::..:::.:::             ..      .**- ;%-.               "
    "      .-****           ;. .....;-;:..              ..::;-...... :.     *++* ;#++=:             "
    "      .;::-*    .:-=======+====+##++*+++=-=--=--=++*++*#+----=+-------*+++*-=#+===:::..        "
    "        .-+#;:-=+*+++++++++++++++*#+*++**+*****+**+*++#+++++++++*+++*#++++**++++++****++=;.    "
    "        -##*****+++++++++++++++++*##*++++************#**++++++++++++**=+++*+=+++++++++++*#+    "
    "          -*#*;=+++**+++++++++++*++*#+************+*#++*++++*++*****+*#+++**+**+***+++++-;     "
    "            :--   .:;-===++=-+++*+++++==----;----=+*+++*+;--;;==::::::;*=+*;;:::::....         "
    "              ;=:         :;:.......   ....   ....  ..... .:;;.        ;#*-                    "
    "                --:         .:.       ..:.     .:.       .::     .   .---#.                    "
    "                  ;--;;=:         .;-;:.         .:--:.         --:;-;:                        "
    "                     .+**=:..:;-=+***+=--;::::;;-=+****+=;:...-+**;                            "
    "                     -++++*****++++++++***********+++++++******+=++.                           "
    "                    .#+**+=*++++**++++++=========++++++**++=*+=**+#+                           "
    "                     ;-;: .#**+-:***+#**##*****#**#+++#-;+**#= .:--.                           "
    "                           :;.   :;. ..::-=--==;;..  :;   .:;                                  "
    "                                                                                               "
    )
    printf "\n+%${box_w}s+\n" | tr ' ' '-'
    for line in "${logo[@]}"; do
        printf "| %-${box_w}s |\n" "$line"
    done
    local -a credit=(
        ""
        "  Gh0stD0rk Killer  |  Created by: The_Gh0stface_Killer"
        "  OSINT | Ethical Hacking | Security Research"
        "  Type 'exit' at any prompt to quit."
        ""
    )
    for line in "${credit[@]}"; do
        printf "| %-${box_w}s |\n" "$line"
    done
    printf "+%${box_w}s+\n\n" | tr ' ' '-'
}

check_exit() {
    local val="$1"
    [[ "${val,,}" == "exit" ]] && echo -e "\nExiting. Goodbye." && exit 0
}

ask() {
    local msg="$1"
    local reply
    printf "%s" "$msg"
    read -r reply
    check_exit "$reply"
    echo "$reply"
}

# ── Engines & Operators ───────────────────────────────────────
declare -A ENGINES=(
    [1]="Google" [2]="Bing" [3]="DuckDuckGo"
    [4]="Yandex" [5]="Twitter" [6]="Bluesky" [7]="Shodan"
)

engine_operators() {
    local engine="$1"
    case "$engine" in
        Google)
            echo "1:site: 2:intitle: 3:inurl: 4:filetype: 5:intext: 6:link:
7:cache: 8:related: 9:allintitle: 10:allinurl: 11:allintext:
12:before: 13:after: 14:OR 15:AND 16:- 17:\""
            ;;
        Bing)
            echo "1:site: 2:intitle: 3:inurl: 4:filetype: 5:inbody:
6:inanchor: 7:contains: 8:feed: 9:hasfeed: 10:ip:
11:loc: 12:before: 13:after: 14:near: 15:OR 16:AND 17:NOT"
            ;;
        DuckDuckGo)
            echo "1:site: 2:intitle: 3:inurl: 4:filetype: 5:intext: 6:- 7:\" 8:OR"
            ;;
        Yandex)
            echo "1:site: 2:url: 3:title: 4:mime: 5:lang: 6:date: 7:+ 8:- 9:\"\" 10:* 11:| 12:&"
            ;;
        Twitter)
            echo "1:from: 2:to: 3:lang: 4:since: 5:until:
6:min_replies: 7:min_faves: 8:min_retweets: 9:filter:links 10:- 11:\" 12:#"
            ;;
        Bluesky)
            echo "1:from: 2:to: 3:mentions: 4:domain: 5:since: 6:until: 7:lang: 8:# 9:@ 10:\""
            ;;
        Shodan)
            echo "1:ip: 2:port: 3:org: 4:country: 5:city: 6:hostname:
7:product: 8:os: 9:net: 10:asn: 11:ssl: 12:http.title:
13:http.html: 14:vuln: 15:has_screenshot:"
            ;;
        *)
            echo ""
            ;;
    esac
}

show_operators() {
    local engine="$1"
    local ops
    ops=$(engine_operators "$engine")
    for pair in $ops; do
        local num="${pair%%:*}"
        local op="${pair#*:}"
        printf "  %s. %s\n" "$num" "$op"
    done
}

get_operator() {
    local engine="$1"
    local choice op ops pair
    ops=$(engine_operators "$engine")
    show_operators "$engine"
    choice=$(ask "[+] Enter operator number (or 'help'): ")
    if [[ "${choice,,}" == "help" ]]; then
        show_help "$engine"
        get_operator "$engine"
        return
    fi
    for pair in $ops; do
        local num="${pair%%:*}"
        local val="${pair#*:}"
        if [[ "$num" == "$choice" ]]; then
            echo "$val"
            return
        fi
    done
    echo "[-] Invalid operator." >&2
    get_operator "$engine"
}

# ── Help ──────────────────────────────────────────────────────
show_help() {
    local engine="$1"
    case "$engine" in
        Google)
            box "Google Operators:
  site:       Restrict to domain.
  intitle:    Keyword in title.
  inurl:      Keyword in URL.
  filetype:   File type filter.
  intext:     Keyword in body.
  cache:      Cached version.
  related:    Related sites.
  before/after: Date filters (YYYY-MM-DD).
  OR / AND / -: Logic operators."
            ;;
        Shodan)
            box "Shodan Operators (requires API key):
  ip:         Search by IP.
  port:       Open port filter.
  org:        Organization name.
  country:    Two-letter country code.
  city:       City name.
  hostname:   Match in hostname.
  product:    Software product.
  os:         Operating system.
  net:        CIDR range.
  vuln:       CVE ID.
  http.title: HTTP page title."
            ;;
        *)
            box "Help not available for $engine. Use operator numbers above."
            ;;
    esac
}

# ── Output formatting ─────────────────────────────────────────
engine_base_url() {
    local engine="$1"
    case "$engine" in
        Google)    echo "https://www.google.com/search?q=" ;;
        Bing)      echo "https://www.bing.com/search?q=" ;;
        DuckDuckGo)echo "https://duckduckgo.com/?q=" ;;
        Yandex)    echo "https://yandex.com/search/?text=" ;;
        Twitter)   echo "https://twitter.com/search?q=" ;;
        Bluesky)   echo "https://bsky.app/search?q=" ;;
        Shodan)    echo "https://www.shodan.io/search?query=" ;;
        *)         echo "" ;;
    esac
}

urlencode() {
    python3 -c "import urllib.parse,sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$1"
}

print_dork() {
    local dork="$1"
    local engine="$2"
    local base url
    base=$(engine_base_url "$engine")
    url="${base}$(urlencode "$dork")"

    case "$OUTPUT_FORMAT" in
        url)  box "[+] Dork for $engine:\n\n  $dork\n\n[URL] $url" ;;
        json) printf '{"engine":"%s","dork":"%s","url":"%s","timestamp":"%s"}\n' \
                  "$engine" "$dork" "$url" "$(date '+%Y-%m-%d %H:%M:%S')" ;;
        *)    box "[+] Dork for $engine:\n\n  $dork\n\n[URL] $url" ;;
    esac
}

# ── Save ──────────────────────────────────────────────────────
save_dork() {
    local dork="$1"
    local engine="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$engine] $dork" >> "$DORKS_FILE"
    echo "[+] Saved to $DORKS_FILE"
}

view_saved_dorks() {
    if [[ ! -f "$DORKS_FILE" ]]; then
        echo "[-] No saved dorks found."
    else
        cat "$DORKS_FILE"
    fi
}

# ── Shodan ────────────────────────────────────────────────────
shodan_query() {
    local query="$1"
    if [[ -z "$SHODAN_API_KEY" ]]; then
        echo "[-] Shodan API key not set. Go to Settings."
        return
    fi
    local encoded
    encoded=$(urlencode "$query")
    local url="https://api.shodan.io/shodan/host/search?key=${SHODAN_API_KEY}&query=${encoded}"
    echo "[+] Querying Shodan..."
    if command -v curl &>/dev/null; then
        local result
        result=$(curl -sf "$url" 2>&1) || { echo "[-] Shodan request failed."; return; }
        echo "$result" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print('[+] Total results:', data.get('total', 0))
for m in data.get('matches', [])[:5]:
    print(f\"  {m.get('ip_str','?')}:{m.get('port','?')}  {m.get('org','?')}  {m.get('product','')}\")
"
    else
        echo "[-] curl not found. Install curl to run Shodan queries."
    fi
}

# ── Templates ─────────────────────────────────────────────────
declare -A TEMPLATE_ENGINES=(
    [1]="Google" [2]="Google" [3]="Google" [4]="Google" [5]="Google"
    [6]="Shodan"  [7]="Shodan"  [8]="Google" [9]="Google" [10]="Twitter"
)

declare -A TEMPLATE_NAMES=(
    [1]="Exposed Login Pages"
    [2]="Open Directory Listing"
    [3]="Exposed Config Files"
    [4]="SQL Errors"
    [5]="Exposed Camera Feeds"
    [6]="Shodan: Open RDP"
    [7]="Shodan: Default Credentials"
    [8]="Pastebin Leaks"
    [9]="Exposed AWS Keys"
    [10]="Twitter OSINT - Target Account"
)

declare -A TEMPLATE_DORKS=(
    [1]='intitle:"login" OR intitle:"admin" inurl:login filetype:php'
    [2]='intitle:"index of /" intext:"parent directory"'
    [3]='filetype:env OR filetype:cfg intext:"password"'
    [4]='intext:"sql syntax near" OR intext:"mysql_fetch"'
    [5]='inurl:"/view/index.shtml" OR intitle:"Live View / - AXIS"'
    [6]='port:3389 os:"Windows"'
    [7]='http.title:"Welcome" port:80 product:"Apache"'
    [8]='site:pastebin.com intext:"password" OR intext:"api_key"'
    [9]='filetype:txt intext:"AKIA" intext:"SECRET"'
    [10]='from:TARGET since:2024-01-01 until:2025-01-01'
)

show_templates() {
    box "[+] Pre-Built Templates"
    for k in "${!TEMPLATE_NAMES[@]}"; do
        echo "  $k. [${TEMPLATE_ENGINES[$k]}] ${TEMPLATE_NAMES[$k]}"
        echo "      ${TEMPLATE_DORKS[$k]}"
        echo
    done | sort
}

template_menu() {
    show_templates
    local choice
    choice=$(ask "[+] Enter template number (or 'back'): ")
    [[ "${choice,,}" == "back" ]] && return
    local dork="${TEMPLATE_DORKS[$choice]:-}"
    local engine="${TEMPLATE_ENGINES[$choice]:-}"
    if [[ -z "$dork" ]]; then
        echo "[-] Invalid selection."
        return
    fi
    print_dork "$dork" "$engine"
    local sv
    sv=$(ask "[+] Save this dork? (yes/no): ")
    [[ "${sv,,}" == "yes" ]] && save_dork "$dork" "$engine"
    if [[ "$engine" == "Shodan" ]]; then
        local run
        run=$(ask "[+] Run Shodan query now? (yes/no): ")
        [[ "${run,,}" == "yes" ]] && shodan_query "$dork"
    fi
}

# ── Timed mode ────────────────────────────────────────────────
timed_mode() {
    box "[+] Timed Dork Mode\n  Cycles through templates. Press Ctrl+C to stop."
    local interval
    interval=$(ask "[+] Interval in seconds: ")
    local keys=(1 2 3 4 5 6 7 8 9 10)
    local idx=0
    while true; do
        local k="${keys[$((idx % ${#keys[@]}))]}"
        local engine="${TEMPLATE_ENGINES[$k]}"
        local dork="${TEMPLATE_DORKS[$k]}"
        local name="${TEMPLATE_NAMES[$k]}"
        echo "[$(date '+%H:%M:%S')] [$engine] $name"
        echo "    $dork"
        [[ "$AUTO_SAVE" == "true" ]] && save_dork "$dork" "$engine"
        idx=$((idx + 1))
        sleep "$interval"
    done
}

# ── Settings ──────────────────────────────────────────────────
settings_menu() {
    while true; do
        box "[+] Settings
  1. Default engine  : $DEFAULT_ENGINE
  2. Auto-save       : $AUTO_SAVE
  3. Output format   : $OUTPUT_FORMAT  (plain | url | json)
  4. Shodan API key  : $([ -n "$SHODAN_API_KEY" ] && echo SET || echo NOT SET)
  5. Back"
        local choice
        choice=$(ask "[+] Choose (1-5): ")
        case "$choice" in
            1)
                for k in "${!ENGINES[@]}"; do echo "  $k. ${ENGINES[$k]}"; done | sort
                local sel
                sel=$(ask "[+] Enter number: ")
                DEFAULT_ENGINE="${ENGINES[$sel]:-$DEFAULT_ENGINE}"
                ;;
            2)
                [[ "$AUTO_SAVE" == "true" ]] && AUTO_SAVE="false" || AUTO_SAVE="true"
                ;;
            3)
                local fmt
                fmt=$(ask "[+] Format (plain/url/json): ")
                [[ "$fmt" =~ ^(plain|url|json)$ ]] && OUTPUT_FORMAT="$fmt" || echo "[-] Invalid."
                ;;
            4)
                local key
                key=$(ask "[+] Enter Shodan API key (blank to clear): ")
                SHODAN_API_KEY="$key"
                ;;
            5) break ;;
            *) echo "[-] Invalid." ;;
        esac
        save_settings
        echo "[+] Settings saved."
    done
}

# ── Build dork ────────────────────────────────────────────────
select_engine() {
    box "[+] Select Search Engine (default: $DEFAULT_ENGINE)"
    for k in "${!ENGINES[@]}"; do
        echo "  $k. ${ENGINES[$k]}"
    done | sort
    local choice
    choice=$(ask "[+] Enter number (or Enter for default): ")
    if [[ -z "$choice" ]]; then
        echo "$DEFAULT_ENGINE"
    elif [[ -n "${ENGINES[$choice]:-}" ]]; then
        echo "${ENGINES[$choice]}"
    else
        echo "[-] Invalid, using default." >&2
        echo "$DEFAULT_ENGINE"
    fi
}

build_dork() {
    local engine="$1"
    local parts=()
    local op phrase more logic

    op=$(get_operator "$engine")
    phrase=$(ask "[+] Value for '$op': ")
    parts+=("${op}${phrase}")

    while true; do
        more=$(ask "[+] Add operator? (yes/no/nested): ")
        case "${more,,}" in
            no) break ;;
            yes)
                logic=$(ask "[+] Chain with AND/OR (or blank): ")
                op=$(get_operator "$engine")
                phrase=$(ask "[+] Value for '$op': ")
                local connector=""
                [[ "$logic" =~ ^(AND|OR)$ ]] && connector=" $logic "
                parts+=("${connector}${op}${phrase}")
                ;;
            nested)
                logic=$(ask "[+] Chain with AND/OR (or blank): ")
                local nested_parts=()
                echo "[+] Building nested group (wrapped in parentheses):"
                while true; do
                    op=$(get_operator "$engine")
                    phrase=$(ask "[+] Value for '$op': ")
                    nested_parts+=("${op}${phrase}")
                    local nm
                    nm=$(ask "[+] Add to this group? (yes/no): ")
                    [[ "${nm,,}" != "yes" ]] && break
                done
                local group="($(IFS=' '; echo "${nested_parts[*]}"))"
                local connector=""
                [[ "$logic" =~ ^(AND|OR)$ ]] && connector=" $logic "
                parts+=("${connector}${group}")
                ;;
            *)
                echo "[-] Enter yes, no, or nested."
                ;;
        esac
    done

    local IFS=""
    echo "${parts[*]}"
}

# ── CLI Arguments ─────────────────────────────────────────────
cli_mode() {
    local engine="" dork="" format="" do_save="false" template="" shodan_q=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --engine)   engine="$2";   shift 2 ;;
            --dork)     dork="$2";     shift 2 ;;
            --format)   format="$2";   shift 2 ;;
            --save)     do_save="true"; shift ;;
            --template) template="$2"; shift 2 ;;
            --shodan)   shodan_q="$2"; shift 2 ;;
            --timed)    timed_mode; exit 0 ;;
            --help|-h)
                echo "Usage: gdk.sh [options]"
                echo "  --engine ENGINE     Search engine name"
                echo "  --dork DORK         Dork string to process"
                echo "  --format FORMAT     Output format (plain|url|json)"
                echo "  --save              Save dork to file"
                echo "  --template NUM      Use pre-built template by number"
                echo "  --shodan QUERY      Run Shodan query"
                echo "  --timed             Run timed generation mode"
                exit 0
                ;;
            *) shift ;;
        esac
    done

    [[ -n "$format" ]] && OUTPUT_FORMAT="$format"

    if [[ -n "$shodan_q" ]]; then
        shodan_query "$shodan_q"
        exit 0
    fi

    if [[ -n "$template" ]]; then
        local tdork="${TEMPLATE_DORKS[$template]:-}"
        local tengine="${TEMPLATE_ENGINES[$template]:-}"
        if [[ -z "$tdork" ]]; then
            echo "[-] Template not found."
            exit 1
        fi
        print_dork "$tdork" "$tengine"
        [[ "$do_save" == "true" ]] && save_dork "$tdork" "$tengine"
        exit 0
    fi

    if [[ -n "$dork" && -n "$engine" ]]; then
        print_dork "$dork" "$engine"
        [[ "$do_save" == "true" ]] && save_dork "$dork" "$engine"
        exit 0
    fi
}

# ── Main ──────────────────────────────────────────────────────
# If any CLI args passed, handle them
if [[ $# -gt 0 ]]; then
    cli_mode "$@"
fi

banner

while true; do
    box "[+] Main Menu
  1. Build a dork
  2. Use a template
  3. View saved dorks
  4. Timed dork generation
  5. Shodan query
  6. Settings
  7. Exit"

    choice=$(ask "[+] Choose (1-7): ")
    case "$choice" in
        1)
            engine=$(select_engine)
            dork=$(build_dork "$engine")
            print_dork "$dork" "$engine"
            if [[ "$AUTO_SAVE" == "true" ]]; then
                save_dork "$dork" "$engine"
            else
                sv=$(ask "[+] Save this dork? (yes/no): ")
                [[ "${sv,,}" == "yes" ]] && save_dork "$dork" "$engine"
            fi
            if [[ "$engine" == "Shodan" ]]; then
                run=$(ask "[+] Run Shodan query now? (yes/no): ")
                [[ "${run,,}" == "yes" ]] && shodan_query "$dork"
            fi
            ;;
        2) template_menu ;;
        3) view_saved_dorks ;;
        4) timed_mode ;;
        5)
            q=$(ask "[+] Enter Shodan query: ")
            shodan_query "$q"
            ;;
        6) settings_menu ;;
        7)
            echo -e "\nThank you for using Gh0stD0rk Killer. Goodbye.\n"
            exit 0
            ;;
        *) echo "[-] Invalid option." ;;
    esac
done
