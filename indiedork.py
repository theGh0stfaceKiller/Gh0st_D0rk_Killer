#!/usr/bin/env python3
"""
IndieDork - Python Edition
A True Indie tool
For ethical hackers, OSINT investigators, and cybersecurity researchers.
"""

import os
import sys
import json
import argparse
import datetime
import time
import urllib.parse
import urllib.request

# ──────────────────────────────────────────────
# CONFIG / SETTINGS
# ──────────────────────────────────────────────
SETTINGS_FILE = "indiedork_settings.json"
DORKS_FILE = "saved_dorks.txt"

DEFAULT_SETTINGS = {
    "default_engine": "Google",
    "auto_save": False,
    "output_format": "plain",  # plain | url | json
    "shodan_api_key": ""
}


def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, "r") as f:
            data = json.load(f)
            # Merge with defaults to handle missing keys
            merged = DEFAULT_SETTINGS.copy()
            merged.update(data)
            return merged
    return DEFAULT_SETTINGS.copy()


def save_settings(settings):
    with open(SETTINGS_FILE, "w") as f:
        json.dump(settings, f, indent=2)


SETTINGS = load_settings()

# ──────────────────────────────────────────────
# OPERATORS
# ──────────────────────────────────────────────
OPERATORS = {
    "Google": {
        "1": "site:", "2": "intitle:", "3": "inurl:", "4": "filetype:",
        "5": "intext:", "6": "link:", "7": "cache:", "8": "related:",
        "9": "allintitle:", "10": "allinurl:", "11": "allintext:",
        "12": "before:", "13": "after:", "14": "define:", "15": "OR",
        "16": "AND", "17": "-", "18": '"'
    },
    "Bing": {
        "1": "site:", "2": "intitle:", "3": "inurl:", "4": "filetype:",
        "5": "inbody:", "6": "inanchor:", "7": "contains:", "8": "feed:",
        "9": "hasfeed:", "10": "ip:", "11": "loc:", "12": "before:",
        "13": "after:", "14": "near:", "15": "related:", "16": "OR",
        "17": "AND", "18": "NOT"
    },
    "DuckDuckGo": {
        "1": "site:", "2": "intitle:", "3": "inurl:", "4": "filetype:",
        "5": "intext:", "6": "-", "7": '"', "8": "OR"
    },
    "Yandex": {
        "1": "site:", "2": "url:", "3": "title:", "4": "mime:",
        "5": "lang:", "6": "date:", "7": "+", "8": "-",
        "9": '""', "10": "*", "11": "|", "12": "&"
    },
    "Twitter": {
        "1": "from:", "2": "to:", "3": "lang:", "4": "since:",
        "5": "until:", "6": "min_replies:", "7": "min_faves:",
        "8": "min_retweets:", "9": "filter:links", "10": "-",
        "11": '"', "12": "#"
    },
    "Bluesky": {
        "1": "from:", "2": "to:", "3": "mentions:", "4": "domain:",
        "5": "since:", "6": "until:", "7": "lang:", "8": "#",
        "9": "@", "10": '"'
    },
    "Shodan": {
        "1": "ip:", "2": "port:", "3": "org:", "4": "country:",
        "5": "city:", "6": "hostname:", "7": "product:", "8": "os:",
        "9": "net:", "10": "asn:", "11": "ssl:", "12": "http.title:",
        "13": "http.html:", "14": "vuln:", "15": "has_screenshot:"
    }
}

INCOMPATIBLE_PAIRS = {
    ("OR", "AND"), ("AND", "OR"),
    ("-", "OR"), ("OR", "-"),
}

# ──────────────────────────────────────────────
# PRE-BUILT TEMPLATES
# NOTE: Templates 5, 6, 7, and 9 return real, live results
# against real systems. Only run these against assets you
# own or have explicit written authorization to test.
# ──────────────────────────────────────────────
TEMPLATES = {
    "1": {
        "name": "Exposed Login Pages",
        "engine": "Google",
        "dork": 'intitle:"login" OR intitle:"admin" inurl:login filetype:php'
    },
    "2": {
        "name": "Open Directory Listing",
        "engine": "Google",
        "dork": 'intitle:"index of /" intext:"parent directory"'
    },
    "3": {
        "name": "Exposed Config Files",
        "engine": "Google",
        "dork": 'filetype:env OR filetype:cfg OR filetype:ini intext:"password"'
    },
    "4": {
        "name": "SQL Errors",
        "engine": "Google",
        "dork": 'intext:"sql syntax near" OR intext:"syntax error has occurred" OR intext:"mysql_fetch"'
    },
    "5": {
        "name": "Exposed Camera Feeds",
        "engine": "Google",
        "dork": 'inurl:"/view/index.shtml" OR intitle:"Live View / - AXIS"'
    },
    "6": {
        "name": "Shodan: Open RDP",
        "engine": "Shodan",
        "dork": 'port:3389 os:"Windows"'
    },
    "7": {
        "name": "Shodan: Default Credentials Devices",
        "engine": "Shodan",
        "dork": 'http.title:"Welcome" port:80 product:"Apache"'
    },
    "8": {
        "name": "Pastebin Leaks",
        "engine": "Google",
        "dork": 'site:pastebin.com intext:"password" OR intext:"api_key"'
    },
    "9": {
        "name": "Exposed AWS Keys",
        "engine": "Google",
        "dork": 'filetype:txt OR filetype:log intext:"AKIA" intext:"SECRET"'
    },
    "10": {
        "name": "Twitter OSINT - Target Account",
        "engine": "Twitter",
        "dork": 'from:TARGET since:2024-01-01 until:2025-01-01'
    },
}

# ──────────────────────────────────────────────
# HELP TEXT
# ──────────────────────────────────────────────
HELP_TEXT = {
    "Google": """
  site:        Restrict to a specific domain.
  intitle:     Match keyword in page title.
  inurl:       Match keyword in URL.
  filetype:    Restrict to file type (pdf, xls, etc).
  intext:      Match keyword in page body.
  link:        Pages linking to a URL.
  cache:       Google's cached version of a page.
  related:     Sites related to a domain.
  allintitle:  All terms must appear in title.
  allinurl:    All terms must appear in URL.
  allintext:   All terms must appear in body.
  before:      Results before YYYY-MM-DD.
  after:       Results after YYYY-MM-DD.
  define:      Dictionary definition.
  OR / AND / - / "": Logic and grouping operators.
""",
    "Bing": """
  site:        Restrict to a domain.
  intitle:     Match in page title.
  inurl:       Match in URL.
  filetype:    Restrict to file type.
  inbody:      Match in body text.
  inanchor:    Match in anchor text.
  contains:    Pages that link to a file type.
  feed:        RSS feed search.
  hasfeed:     Pages with RSS/Atom feeds.
  ip:          Pages on a specific IP.
  loc:         Region-specific results.
  before/after: Date filters (YYYY-MM-DD).
  near:        Proximity (word1 near:5 word2).
  OR / AND / NOT: Logic operators.
""",
    "DuckDuckGo": """
  site:        Restrict to domain.
  intitle:     Match in title.
  inurl:       Match in URL.
  filetype:    Restrict to file type.
  intext:      Match in body.
  -            Exclude a term.
  "phrase"     Exact phrase match.
  OR           Either term.
""",
    "Yandex": """
  site:        Restrict to site.
  url:         Match in URL.
  title:       Match in page title.
  mime:        Restrict by MIME type.
  lang:        Language code filter.
  date:        Date range filter.
  +            Mandatory inclusion.
  -            Exclude term.
  ""            Exact phrase.
  *            Wildcard.
  |            OR operator.
  &            AND operator.
""",
    "Twitter": """
  from:        Tweets from a user.
  to:          Tweets sent to a user.
  lang:        Language code (en, es, etc).
  since:       After date (YYYY-MM-DD).
  until:       Before date (YYYY-MM-DD).
  min_replies: Minimum reply count.
  min_faves:   Minimum like count.
  min_retweets:Minimum retweet count.
  filter:links Only tweets with links.
  -            Exclude a term.
  "phrase"     Exact phrase.
  #hashtag     Search by hashtag.
""",
    "Bluesky": """
  from:        Posts from a user handle.
  to:          Posts directed at a user.
  mentions:    Posts mentioning a user.
  domain:      Posts linking to a domain.
  since:       After date (YYYY-MM-DD).
  until:       Before date (YYYY-MM-DD).
  lang:        Language code filter.
  #            Hashtag search.
  @            Mention search.
  "phrase"     Exact phrase match.
""",
    "Shodan": """
  NOTE: Shodan requires your own API key.
  Set it via the Settings menu.

  ip:          Search by IP address.
  port:        Filter by open port.
  org:         Organization / ISP name.
  country:     Two-letter country code.
  city:        City name.
  hostname:    Match in hostname.
  product:     Software product name.
  os:          Operating system.
  net:         CIDR network range.
  asn:         Autonomous system number.
  ssl:         SSL certificate field.
  http.title:  Match in HTTP title.
  http.html:   Match in HTML body.
  vuln:        CVE identifier.
  has_screenshot: Devices with screenshots.
"""
}

SEARCH_ENGINE_URLS = {
    "Google":    "https://www.google.com/search?q=",
    "Bing":      "https://www.bing.com/search?q=",
    "DuckDuckGo":"https://duckduckgo.com/?q=",
    "Yandex":    "https://yandex.com/search/?text=",
    "Twitter":   "https://twitter.com/search?q=",
    "Bluesky":   "https://bsky.app/search?q=",
    "Shodan":    "https://www.shodan.io/search?query=",
}

# ──────────────────────────────────────────────
# DISPLAY HELPERS
# ──────────────────────────────────────────────
BOX_WIDTH = 91


def box(message):
    print("\n+" + "-" * BOX_WIDTH + "+")
    for line in message.splitlines():
        print("| {:<{w}} |".format(line, w=BOX_WIDTH))
    print("+" + "-" * BOX_WIDTH + "+\n")


def banner():
    logo_lines = [
        ' ___           _ _      ____             _    ',
        '|_ _|_ __   __| (_) ___|  _ \\  ___  _ __| | __',
        " | || '_ \\ / _` | |/ _ \\ | | |/ _ \\| '__| |/ /",
        ' | || | | | (_| | |  __/ |_| | (_) | |  |   < ',
        '|___|_| |_|\\__,_|_|\\___|____/ \\___/|_|  |_|\\_\\',
    ]
    box_w = 54
    print("\n+" + "-" * box_w + "+")
    for line in logo_lines:
        print("| {:<{w}} |".format(line, w=box_w))
    for line in [
        "",
        "  IndieDork  |  A True Indie Tool",
        "  OSINT | Ethical Hacking | Security Research",
        "  Type 'exit' at any prompt to quit.",
        "",
    ]:
        print("| {:<{w}} |".format(line, w=box_w))
    print("+" + "-" * box_w + "+\n")

def check_exit(val):
    if val.strip().lower() == "exit":
        print("\nExiting. Goodbye.")
        sys.exit(0)


def prompt(msg):
    val = input(msg).strip()
    check_exit(val)
    return val

# ──────────────────────────────────────────────
# OUTPUT FORMATTING
# ──────────────────────────────────────────────
def format_dork(dork, engine, fmt):
    if fmt == "url":
        base = SEARCH_ENGINE_URLS.get(engine, "")
        return base + urllib.parse.quote_plus(dork)
    elif fmt == "json":
        return json.dumps({"engine": engine, "dork": dork, "timestamp": str(datetime.datetime.now())}, indent=2)
    return dork  # plain


def print_dork(dork, engine):
    fmt = SETTINGS.get("output_format", "plain")
    output = format_dork(dork, engine, fmt)
    box(f"[+] Generated dork for {engine}:\n\n    {dork}\n\n[URL] {format_dork(dork, engine, 'url')}")
    if fmt == "json":
        print(output)

# ──────────────────────────────────────────────
# SAVE DORKS
# ──────────────────────────────────────────────
def save_dork(dork, engine):
    with open(DORKS_FILE, "a") as f:
        ts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"[{ts}] [{engine}] {dork}\n")
    print(f"[+] Dork saved to {DORKS_FILE}\n")


def view_saved_dorks():
    if not os.path.exists(DORKS_FILE):
        print("[-] No saved dorks found.\n")
        return
    print("\n[+] Saved Dorks:\n")
    with open(DORKS_FILE, "r") as f:
        print(f.read())

# ──────────────────────────────────────────────
# OPERATOR VALIDATION
# ──────────────────────────────────────────────
def validate_operator_combo(parts):
    operators_used = []
    for part in parts:
        op = part.split()[0] if part else ""
        operators_used.append(op)
    for i in range(len(operators_used) - 1):
        pair = (operators_used[i], operators_used[i + 1])
        if pair in INCOMPATIBLE_PAIRS:
            print(f"[-] Warning: '{pair[0]}' and '{pair[1]}' may conflict in this combination.\n")


# ──────────────────────────────────────────────
# SHODAN API
# ──────────────────────────────────────────────
def shodan_search(query):
    api_key = SETTINGS.get("shodan_api_key", "").strip()
    if not api_key:
        print("[-] No Shodan API key set. Go to Settings to add your key.\n")
        return
    url = f"https://api.shodan.io/shodan/host/search?key={api_key}&query={urllib.parse.quote(query)}"
    print(f"[+] Querying Shodan: {query}\n")
    try:
        req = urllib.request.urlopen(url, timeout=10)
        data = json.loads(req.read().decode())
        total = data.get("total", 0)
        print(f"[+] Total results: {total}\n")
        for match in data.get("matches", [])[:5]:
            ip = match.get("ip_str", "N/A")
            port = match.get("port", "N/A")
            org = match.get("org", "N/A")
            product = match.get("product", "")
            print(f"  {ip}:{port}  |  {org}  |  {product}")
        print()
    except Exception as e:
        print(f"[-] Shodan query failed: {e}\n")


# ──────────────────────────────────────────────
# TEMPLATES MENU
# ──────────────────────────────────────────────
def template_menu():
    box("[+] Pre-Built Dork Templates")
    for k, v in TEMPLATES.items():
        print(f"  {k}. [{v['engine']}] {v['name']}")
        print(f"      {v['dork']}\n")
    choice = prompt("[+] Enter template number to use (or 'back'): ")
    if choice.lower() == "back":
        return
    tpl = TEMPLATES.get(choice)
    if not tpl:
        print("[-] Invalid selection.\n")
        return
    dork = tpl["dork"]
    engine = tpl["engine"]
    print_dork(dork, engine)
    save_choice = prompt("[+] Save this dork? (yes/no): ").lower()
    if save_choice == "yes":
        save_dork(dork, engine)
    if engine == "Shodan":
        run_it = prompt("[+] Run Shodan query now? (yes/no): ").lower()
        if run_it == "yes":
            shodan_search(dork)


# ──────────────────────────────────────────────
# SETTINGS MENU
# ──────────────────────────────────────────────
def settings_menu():
    while True:
        box(f"""[+] Settings
  1. Default engine    : {SETTINGS['default_engine']}
  2. Auto-save dorks   : {SETTINGS['auto_save']}
  3. Output format     : {SETTINGS['output_format']}  (plain | url | json)
  4. Shodan API key    : {'SET' if SETTINGS['shodan_api_key'] else 'NOT SET'}
  5. Back""")
        choice = prompt("[+] Choose setting to change (1-5): ")
        if choice == "1":
            engines = list(OPERATORS.keys())
            for i, e in enumerate(engines, 1):
                print(f"  {i}. {e}")
            sel = prompt("[+] Choose engine number: ")
            try:
                SETTINGS["default_engine"] = engines[int(sel) - 1]
            except (ValueError, IndexError):
                print("[-] Invalid.\n")
        elif choice == "2":
            SETTINGS["auto_save"] = not SETTINGS["auto_save"]
        elif choice == "3":
            fmt = prompt("[+] Enter format (plain / url / json): ").lower()
            if fmt in ("plain", "url", "json"):
                SETTINGS["output_format"] = fmt
            else:
                print("[-] Invalid format.\n")
        elif choice == "4":
            key = prompt("[+] Enter Shodan API key (leave blank to clear): ")
            SETTINGS["shodan_api_key"] = key
        elif choice == "5":
            break
        save_settings(SETTINGS)
        print("[+] Settings saved.\n")


# ──────────────────────────────────────────────
# TIMED / AUTOMATED DORK GENERATION
# ──────────────────────────────────────────────
def timed_dork_mode():
    """Generate dorks on a timer using a template set."""
    box("[+] Timed Dork Generation Mode\n\n  Cycles through templates at set interval.\n  Press Ctrl+C to stop.")
    try:
        interval = int(prompt("[+] Interval in seconds between dorks: "))
    except ValueError:
        print("[-] Invalid interval.\n")
        return
    tpl_list = list(TEMPLATES.values())
    idx = 0
    try:
        while True:
            tpl = tpl_list[idx % len(tpl_list)]
            ts = datetime.datetime.now().strftime("%H:%M:%S")
            print(f"\n[{ts}] [{tpl['engine']}] {tpl['name']}")
            print(f"      {tpl['dork']}")
            if SETTINGS.get("auto_save"):
                save_dork(tpl["dork"], tpl["engine"])
            idx += 1
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\n[+] Timed mode stopped.\n")


# ──────────────────────────────────────────────
# OPERATOR SELECTION (interactive)
# ──────────────────────────────────────────────
def select_engine():
    engines = list(OPERATORS.keys())
    default = SETTINGS.get("default_engine", "Google")
    box(f"[+] Select Search Engine  (default: {default})")
    for i, e in enumerate(engines, 1):
        print(f"  {i}. {e}")
    choice = prompt(f"\n[+] Enter number (or press Enter for default): ")
    if not choice:
        return default
    try:
        return engines[int(choice) - 1]
    except (ValueError, IndexError):
        print("[-] Invalid, using default.\n")
        return default


def select_operator(engine):
    ops = OPERATORS.get(engine, {})
    for k, v in ops.items():
        print(f"  {k}. {v}")
    choice = prompt("\n[+] Enter operator number (or 'help'): ")
    if choice.lower() == "help":
        print(HELP_TEXT.get(engine, "No help available for this engine."))
        return select_operator(engine)
    if choice in ops:
        return ops[choice]
    print("[-] Invalid operator.\n")
    return select_operator(engine)


def suggest_operators(engine, current_ops):
    """Suggest compatible operators based on what's already been chosen."""
    ops = list(OPERATORS.get(engine, {}).values())
    suggestions = [op for op in ops if op not in current_ops][:3]
    if suggestions:
        print(f"[~] Suggestions: {', '.join(suggestions)}\n")


# ──────────────────────────────────────────────
# NESTED / ADVANCED OPERATOR CHAINING
# ──────────────────────────────────────────────
def build_nested_group(engine):
    """Build a grouped sub-expression like: (intitle:admin inurl:login)"""
    parts = []
    box("[+] Build Nested Group\n  Operators added here will be wrapped in parentheses.")
    while True:
        op = select_operator(engine)
        phrase = prompt(f"[+] Value for '{op}': ")
        parts.append(f"{op}{phrase}")
        more = prompt("[+] Add another to this group? (yes/no): ").lower()
        if more != "yes":
            break
    return "(" + " ".join(parts) + ")"


def build_dork(engine):
    parts = []
    used_ops = []
    op = select_operator(engine)
    used_ops.append(op)
    phrase = prompt(f"[+] Value for '{op}': ")
    parts.append(f"{op}{phrase}")

    while True:
        suggest_operators(engine, used_ops)
        more = prompt("[+] Add another operator? (yes/no/nested): ").lower()
        if more == "no":
            break
        elif more == "nested":
            logic = prompt("[+] Chain with (AND/OR/blank): ").upper()
            group = build_nested_group(engine)
            connector = f" {logic} " if logic in ("AND", "OR") else " "
            parts.append(connector + group)
        elif more == "yes":
            logic = prompt("[+] Chain with (AND/OR/blank): ").upper()
            op = select_operator(engine)
            used_ops.append(op)
            phrase = prompt(f"[+] Value for '{op}': ")
            connector = f" {logic} " if logic in ("AND", "OR") else " "
            parts.append(connector + f"{op}{phrase}")
        else:
            print("[-] Enter yes, no, or nested.\n")
            continue
        validate_operator_combo(parts)

    return "".join(parts)


# ──────────────────────────────────────────────
# CLI ARGS
# ──────────────────────────────────────────────
def parse_args():
    parser = argparse.ArgumentParser(
        description="IndieDork - Dork Generator",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("--engine", help="Search engine (Google, Bing, DuckDuckGo, Yandex, Twitter, Bluesky, Shodan)")
    parser.add_argument("--dork", help="Dork string to format/run directly")
    parser.add_argument("--format", choices=["plain", "url", "json"], help="Output format")
    parser.add_argument("--save", action="store_true", help="Save the dork to file")
    parser.add_argument("--template", help="Run a template by number (1-10)")
    parser.add_argument("--timed", action="store_true", help="Run timed dork generation mode")
    parser.add_argument("--shodan", help="Run a Shodan query string directly")
    return parser.parse_args()


def handle_cli(args):
    if args.format:
        SETTINGS["output_format"] = args.format
    if args.template:
        tpl = TEMPLATES.get(args.template)
        if tpl:
            engine = tpl["engine"]
            dork = tpl["dork"]
            print_dork(dork, engine)
            if args.save:
                save_dork(dork, engine)
        else:
            print("[-] Template not found.")
        sys.exit(0)
    if args.shodan:
        shodan_search(args.shodan)
        sys.exit(0)
    if args.dork and args.engine:
        print_dork(args.dork, args.engine)
        if args.save:
            save_dork(args.dork, args.engine)
        sys.exit(0)
    if args.timed:
        timed_dork_mode()
        sys.exit(0)


# ──────────────────────────────────────────────
# MAIN MENU
# ──────────────────────────────────────────────
def main_menu():
    banner()
    while True:
        box("""[+] Main Menu

  1. Build a dork
  2. Use a template
  3. View saved dorks
  4. Timed dork generation
  5. Shodan query
  6. Settings
  7. Exit""")
        choice = prompt("[+] Choose an option (1-7): ")

        if choice == "1":
            engine = select_engine()
            dork = build_dork(engine)
            print_dork(dork, engine)
            do_save = SETTINGS.get("auto_save")
            if not do_save:
                do_save = prompt("[+] Save this dork? (yes/no): ").lower() == "yes"
            if do_save:
                save_dork(dork, engine)
            if engine == "Shodan":
                if prompt("[+] Run Shodan query now? (yes/no): ").lower() == "yes":
                    shodan_search(dork)

        elif choice == "2":
            template_menu()

        elif choice == "3":
            view_saved_dorks()

        elif choice == "4":
            timed_dork_mode()

        elif choice == "5":
            query = prompt("[+] Enter Shodan query: ")
            shodan_search(query)

        elif choice == "6":
            settings_menu()

        elif choice == "7":
            print("\nThank you for using IndieDork. Goodbye.\n")
            sys.exit(0)

        else:
            print("[-] Invalid option.\n")


# ──────────────────────────────────────────────
# ENTRY POINT
# ──────────────────────────────────────────────
if __name__ == "__main__":
    args = parse_args()
    # If any meaningful CLI arg is present, handle it and exit
    if any([args.engine, args.dork, args.template, args.timed, args.shodan]):
        handle_cli(args)
    else:
        main_menu()
