# IndieDork 

<img width="754" height="716" alt="indiedork" src="https://github.com/user-attachments/assets/606b6060-0d9a-4498-a2a4-a1c351d0962b" />


*A True Indie tool*

Advanced search dork generator for OSINT investigators, ethical hackers, and security researchers, built and maintained as part of [True Indie](https://trueindie661.substack.com), where I teach the methods behind tools like this one.

## Supported Search Engines

| Engine | Notes |
|---|---|
| Google | Full operator set |
| Bing | Includes proximity and content filters |
| DuckDuckGo | Core operators |
| Yandex | Unique operators (lang, mime, date) |
| Twitter | Time, engagement, and user filters |
| Bluesky | Handle, domain, hashtag, date filters |
| Shodan | Requires your own API key (see below) |

## Features

- **Dork Builder** — Interactive operator selection with chaining (AND / OR)
- **Nested Operators** — Group sub-expressions in parentheses for complex queries
- **Pre-Built Templates** — 10 ready-to-use dorks for common OSINT and recon tasks
- **Save Dorks** — Append any dork to `saved_dorks.txt` with timestamp
- **View Saved Dorks** — Review your history from within the tool
- **Auto-Save** — Optionally save every dork automatically
- **Output Formats** — plain, url (clickable search link), or json
- **Interactive Help** — Per-engine operator reference, type `help` at any prompt
- **Operator Suggestions** — Tool suggests compatible operators as you build
- **Error Handling** — Detects conflicting operator combinations and warns you
- **Shodan Integration** — Query Shodan directly with your API key
- **Timed Mode** — Cycles through templates on a set interval (automated recon)
- **CLI Arguments** — Generate dorks without the interactive menu
- **Persistent Settings** — Your preferences saved between sessions

## Versions

| File | Language | Requirements |
|---|---|---|
| `indiedork.py` | Python 3 | Python 3.7+, no pip deps |
| `indiedork.sh` | Bash | Bash 4+, curl (Shodan) |
| `indiedork.ps1` | PowerShell | PowerShell 5.1+ |

## Installation

```
git clone https://github.com/[your-username]/IndieDork.git
cd IndieDork
```

No external dependencies required for the core tool.

For Shodan queries, set your API key in the Settings menu. Never hardcode your API key in the script. Get your key at: https://account.shodan.io

## Usage

**Python**
```
python3 indiedork.py
```

**Bash**
```
chmod +x indiedork.sh
./indiedork.sh
```

**PowerShell**
```
.\indiedork.ps1
```

## CLI Arguments

**Python**
```
# Format and output a dork directly
python3 indiedork.py --engine Google --dork 'site:example.com filetype:pdf' --format url

# Run a pre-built template
python3 indiedork.py --template 1 --save

# Run Shodan query
python3 indiedork.py --shodan 'port:3389 os:Windows'

# Timed generation mode
python3 indiedork.py --timed
```

**Bash**
```
./indiedork.sh --engine Google --dork 'site:example.com' --format url --save
./indiedork.sh --template 3
./indiedork.sh --shodan 'port:22 country:US'
./indiedork.sh --timed
```

**PowerShell**
```
.\indiedork.ps1 -Engine Google -Dork 'site:example.com filetype:pdf' -Format url
.\indiedork.ps1 -Template 1 -Save
.\indiedork.ps1 -Shodan 'port:3389 os:Windows'
.\indiedork.ps1 -Timed
```

## Pre-Built Templates

| # | Name | Engine |
|---|---|---|
| 1 | Exposed Login Pages | Google |
| 2 | Open Directory Listing | Google |
| 3 | Exposed Config Files | Google |
| 4 | SQL Errors | Google |
| 5 | Exposed Camera Feeds | Google |
| 6 | Shodan: Open RDP | Shodan |
| 7 | Shodan: Default Credentials | Shodan |
| 8 | Pastebin Leaks | Google |
| 9 | Exposed AWS Keys | Google |
| 10 | Twitter OSINT, Target | Twitter |

> ⚠️ **Templates 5, 6, 7, and 9 return real, live results.** These queries surface systems and credentials that are actually exposed on the internet right now, not sample or sandbox data. Only run these against assets you own or have explicit written authorization to test. Running them against anything else can cross into unauthorized access, which carries real legal consequences regardless of intent.

## Example Session

```
[+] Main Menu
  1. Build a dork
  2. Use a template
  3. View saved dorks
  4. Timed dork generation
  5. Shodan query
  6. Settings
  7. Exit

[+] Choose (1-7): 1

[+] Select Search Engine (default: Google)
  1. Bluesky
  2. Bing
  3. DuckDuckGo
  4. Google
  5. Shodan
  6. Twitter
  7. Yandex

[+] Enter number: 4

  1. site:   2. intitle:   3. inurl:   4. filetype:
  5. intext: 6. link:      7. cache:   8. related: ...

[+] Enter operator number (or 'help'): 5
[+] Value for 'intext:': password
[~] Suggestions: site:, filetype:, intitle:

[+] Add operator? (yes/no/nested): nested
[+] Chain with AND/OR (or blank): AND
[+] Nested Group Builder
  1. site:   2. intitle:   ...
[+] Enter operator number: 1
[+] Value for 'site:': pastebin.com
[+] Add another to this group? (yes/no): no

[+] Dork for Google:

    intext:password AND (site:pastebin.com)

[URL] https://www.google.com/search?q=intext%3Apassword+AND+%28site%3Apastebin.com%29
```

## Settings

All settings are saved between sessions.

| Setting | Options | Default |
|---|---|---|
| Default Engine | Any supported engine | Google |
| Auto-Save | true / false | false |
| Output Format | plain / url / json | plain |
| Shodan API Key | Your key (stored locally) | not set |

## Shodan Integration

Shodan queries run directly against the Shodan REST API. You must supply your own API key, it is never included in this tool.

Settings → Shodan API Key → [paste your key]

Keys are stored in:
- Python / Bash: `~/.indiedork_settings` or `indiedork_settings.json`
- PowerShell: `~/.indiedork_settings.json`

## Ethical Use

This tool is built for authorized security research, OSINT investigation, and education, the same standard I hold every piece of tradecraft I teach on True Indie to. Always get proper, explicit authorization before testing any system that isn't your own. The templates in this tool, especially the ones flagged above, return real data about real, currently-exposed systems. Misusing that is on you, not the tool, and it can carry real legal consequences.

If you want to learn the thinking behind dorking, OSINT collection, and the broader intelligence cycle this tool fits into, that's what [True Indie](https://trueindie661.substack.com) is for.

## Author

Built and maintained as part of **True Indie**
[trueindie661.substack.com](https://trueindie661.substack.com)

## License

For personal and professional security research use.



