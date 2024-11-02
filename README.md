# Gh0stD0rk Killer 👻🔪

Welcome to **Gh0stD0rk Killer**, a tool designed for ethical hackers, OSINT investigators, and cybersecurity researchers to create advanced search engine dorks for refining search results on Google, Bing, DuckDuckGo, and Yandex. With options for chaining multiple operators, this tool lets you build complex queries for deep-dive investigations.

## Features

- **Search Engine Support**: Compatible with Google, Bing, DuckDuckGo, and Yandex.
- **Advanced Operators**: Supports unique operators for Yandex alongside common operators for Google, Bing, and DuckDuckGo.
- **Dynamic Help Menu**: Displays detailed explanations for each operator, tailored for each search engine.
- **Operator Chaining**: Allows combining multiple operators with `AND` and `OR` to refine searches further.
- **Improved Input Validation**: Ensures only valid operators are chosen for each search engine.

## How It Works

The script guides users through the following steps:
1. **Search Engine Selection**: Choose a search engine from Google, Bing, DuckDuckGo, or Yandex.
2. **Operator Selection**: Select advanced operators like `site:`, `intitle:`, `date:`, and many others. Type `help` anytime to see available operators and descriptions.
3. **Search Phrase Input**: Enter the search phrase to use with the selected operator.
4. **Logical Chaining**: Optionally combine multiple operators with logical operators (AND/OR).
5. **Final Dork Output**: The script outputs a complete dork, which can be copied directly into a search engine for investigation.

## Requirements

No external dependencies are required. This script runs on pure Python, making it lightweight and easy to run.

## Installation and Usage

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/Gh0stD0rk-Killer.git
   
   cd Gh0stD0rk-Killer
   ```

2. **Run the Script**:
   ```bash
   sudo python gdk.py
   ```

3. **Follow the Prompts** to create a customized search dork.

### Example

Here’s how the script may look in use:

```
┌──(kali㉿kali)
└─$ sudo python gdk.py

+-------------------------------------------------------------------------------------------+
|                                                                                             |
|           ('-. .-.            .-')   .-') _   _ .-') _            _  .-')  .-. .-')         |
|          ( xx )  /           ( xx ).(  xx) ) ( (  xx) )          ( \( xx ) \  ( xx )        |
|   ,----.   ,--. ,--.  .----.  (_)---\_)     '._ \     .'_   .----.  ,------. ,--. ,--.      |
|  '  .-./-')|  | |  | /  ..  \ /    _ ||'--...__),`'--..._) /  ..   \ |   /`. '|  .'   /     |
|  |  |_( xx )   .|  |.  /  \  .\  :` `.'--.  .--'|  |   \  '. /  \  . |  /  | ||      /,     |
|  |  | .--, \       ||  |  '   |'..`''.)  |  |   |  |   ' || |    ' | | |_.'  ||     ' _)    |
| (|  | '. (_/  .-.  |'  \  /  '.-._)   \  |  |   |  |   / :'  \   / ' |  .  '.'|  .   \      |
|  |  '--'  ||  | |  | \  `'  / \       /  |  |   |  '--'  / \  ` ' /  |  |\  \ |  |\   \     |
|   `------' `--' `--'  `---''   `-----'   `--'   `-------'   `---''  `--' '--'`--' '--'      |
|  .-. .-')                               ('-.  _  .-')                                       |
|  \  ( xx )                            _(  xx)( \( xx )                                      |
|  ,--. ,--. ,-.-')  ,--.      ,--.    (,------.,------.                                      |
|  |  .'   / |  |xx) |  |.-')  |  |.-') |  .---'|   /`. '                                     |
|  |      /, |  |  \ |  | xx ) |  | xx )|  |    |  /  | |                                     |
|  |     ' _)|  |(_/ |  |`-' | |  |`-' (|  '--. |  |_.' |                                     |
|  |  .   \ ,|  |_.'(|  '---.'(|  '---.'|  .--' |  .  '.'                                     |
|  |  |\   (_|  |    |      |  |      | |  `---.|  |\  \                                      |
|  `--' '--' `--'    `------'  `------' `------'`--' '--'                                     |
|                                                                                             |
|     Created by: The_Gh0stface_Killer                                                        |
|                                                                                             |
|     This script will help you generate dorks for search engines.                            |
|                                                                                             |
|     Advanced operators will help you refine your search.                                    |
|                                                                                             |
|     Type 'exit' at any prompt to quit the program.                                          |
|                                                                                             |
+-------------------------------------------------------------------------------------------+


+-------------------------------------------------------------------------------------------+
|                                                                                             |
| [+] Which search engine are you using?                                                      |
|                                                                                             |
|  1. Google                                                                                  |
|  2. Bing                                                                                    |
|  3. DuckDuckGo                                                                              |
|  4. Yandex                                                                                  |
|                                                                                             |
+-------------------------------------------------------------------------------------------+

[+] Enter the number corresponding to your choice (1-4): 1


+-------------------------------------------------------------------------------------------+
|                                                                                             |
| [+] Select the number corresponding to your operator of choice for Google:                  |
|                                                                                             |
| [-] Type 'help' to display detailed explanations of each operator.                          |
|                                                                                             |
+-------------------------------------------------------------------------------------------+

1. site:
2. intitle:
3. inurl:
4. filetype:
5. intext:
6. link:

[+] Enter the number corresponding to your operator of choice, or type 'help': 5

[+] Enter the phrase to search for: chicken sandwiches

[+] Would you like to add another operator? (yes/no): yes

[+] Do you want to use AND or OR to chain the operators? (AND/OR): AND


+-------------------------------------------------------------------------------------------+
|                                                                                             |
| [+] Select the number corresponding to your operator of choice for Google:                  |
|                                                                                             |
| [-] Type 'help' to display detailed explanations of each operator.                          |
|                                                                                             |
+-------------------------------------------------------------------------------------------+

1. site:
2. intitle:
3. inurl:
4. filetype:
5. intext:
6. link:

[+] Enter the number corresponding to your operator of choice, or type 'help': 1

[+] Enter the phrase to search for: burgerking.com

[+] Would you like to add another operator? (yes/no): no


+-------------------------------------------------------------------------------------------+
| [+] Here is your generated search dork for Google:                                          |
|                                                                                             |
| [-] intext:chicken sandwiches AND site:burgerking.com                                       |
+-------------------------------------------------------------------------------------------+


[+] Would you like to generate another dork? (yes/no): no


Thank you for using Gh0stD0rk Killer. Goodbye!

```

### Help Menu

The tool provides an interactive help menu that varies by search engine. Simply type `help` at any operator selection prompt to get descriptions.

- **Google, Bing, DuckDuckGo Operators**:
  - `site:` - Limits search results to a specific site.
  - `intitle:` - Searches for keywords in the title of a page.
  - `inurl:` - Filters results by keywords in the URL.
  - `filetype:` - Restricts results to a specific file type.
  - `intext:` - Searches within the page text.
  - `link:` - Finds pages linking to a URL.

- **Yandex Operators**:
  - `+` - Requires word inclusion.
  - `-` - Excludes word.
  - `""` - Exact phrase search.
  - `*` - Wildcard.
  - `|` - OR operator.
  - `~~` - NOT operator.
  - `url:` - Search in a specific URL.
  - `site:` - Domain-limited search.
  - `domain:` - Limits to the main domain.
  - `title:` - Search keywords in title.
  - `date:` - Filters by date.
  
## Planned Improvements

Future developments include:
- Expanding search engines (Yahoo, Baidu, etc.).
- Researching and cleaning up current search engines operators.
- Saving past queries to a file for reuse.
- Clean up user interface and presentation of dorks.
- And much more!


Thank you for choosing Gh0stD0rk Killer! 👻🔪


