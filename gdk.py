def display_in_box(message):
    # Encapsulates text in a bordered ASCII box for cleaner output
    box_width = 91
    print("\n+" + "-" * box_width + "+")
    for line in message.splitlines():
        print("| {:<{width}} |".format(line, width=box_width))
    print("+" + "-" * box_width + "+\n")

def display_welcome_message():
    welcome_message = """
          ('-. .-.            .-')   .-') _   _ .-') _            _  .-')  .-. .-')    
         ( xx )  /           ( xx ).(  xx) ) ( (  xx) )          ( \\( xx ) \\  ( xx )   
 ,----.   ,--. ,--.  .----.  (_)---\\_)     '._ \\     .'_   .----.  ,------. ,--. ,--.   
'  .-./-')|  | |  | /  ..  \\ /    _ ||'--...__),`'--..._) /  ..  \\ |   /`. '|  .'   /   
|  |_( xx )   .|  |.  /  \\  .\\  :` `.'--.  .--'|  |  \\  '.  /  \\  .|  /  | ||      /,   
|  | .--, \\       ||  |  '  | '..`''.)  |  |   |  |   ' ||  |  '  ||  |_.' ||     ' _)  
(|  | '. (_/  .-.  |'  \\  /  '.-._)   \\  |  |   |  |   / :'  \\  /  '|  .  '.'|  .   \\    
 |  '--'  ||  | |  | \\  `'  / \\       /  |  |   |  '--'  / \\  `'  / |  |\\  \\ |  |\\   \\  
  `------' `--' `--'  `---''   `-----'   `--'   `-------'   `---''  `--' '--'`--' '--'   
 .-. .-')                               ('-.  _  .-')                                     
 \\  ( xx )                            _(  xx)( \\( xx )                                   
 ,--. ,--. ,-.-')  ,--.      ,--.    (,------.,------.                                    
 |  .'   / |  |xx) |  |.-')  |  |.-') |  .---'|   /`. '                                   
 |      /, |  |  \\ |  | xx ) |  | xx )|  |    |  /  | |                                   
 |     ' _)|  |(_/ |  |`-' | |  |`-' (|  '--. |  |_.' |                                   
 |  .   \\ ,|  |_.'(|  '---.'(|  '---.'|  .--' |  .  '.'                                   
 |  |\\   (_|  |    |      |  |      | |  `---.|  |\\  \\                                   
 `--' '--' `--'    `------'  `------' `------'`--' '--'                                  
                                                                                          
    Created by: The_Gh0stface_Killer
    
    This script will help you generate dorks for search engines.
    Advanced operators will help you refine your search.
    
    Type 'exit' at any prompt to quit the program.
    """
    display_in_box(welcome_message)

def check_exit(input_str):
    if input_str.strip().lower() == "exit":
        print("\nExiting the script. Goodbye!")
        exit()

def show_help_menu(search_engine):
    if search_engine == "Yandex":
        help_message = """
        +     - Searches with mandatory inclusion of the word.
        -     - Excludes pages with the word.
        ""   - Exact phrase search.
        *     - Wildcard for any word or character.
        |     - OR operator for optional terms.
        ~~    - NOT operator, excluding terms.
        ~     - Approximate word search.
        !     - Enforce word order.
        !!    - Strict match for word.
        &     - AND operator to combine terms.
        && or << - Narrow search for terms near each other.
        /+n   - Search where terms appear within +n words.
        /-n   - Search where terms appear within -n words.
        &&/n  - Search terms within n words of each other.
        url:  - Search within a specific URL.
        site:  - Search within a specific site or domain.
        domain: - Search within a main domain only.
        title: - Limits results to pages with keywords in the title.
        mime:  - Search specific MIME types.
        lang:  - Filter by language.
        date:  - Filter by date.
        $ anchor() - Anchored search.
        """
    elif search_engine == "Bing":
        help_message = """
        "           - Exact Phrase Search: Finds exact matches for a phrase.
        OR          - Logical OR: Finds pages with one of the specified words.
        AND         - Logical AND: Ensures all words appear in results.
        NOT or -    - Exclude Words: Excludes specified words.
        site:       - Site Search: Limits results to a domain.
        inurl:      - URL Keyword Search: Finds words in the URL.
        intitle:    - Title Keyword Search: Finds words in the title.
        inanchor:   - Anchor Text Search: Finds pages with specific anchor text.
        filetype:   - File Type Search: Limits results to file types (e.g., PDF).
        inbody:     - Body Content Search: Looks for words in body text.
        feed:       - RSS Feeds: Finds RSS feeds for a topic.
        near:X      - Proximity Search: Finds words within X words of each other.
        before:     - Date Filter: Finds results before a date.
        after:      - Date Filter: Finds results after a date.
        hasfeed:    - Finds pages that contain an RSS or Atom feed.
        loc: or location: - Region-Specific Search: Limits results by region.
        ip:         - IP Search: Finds sites hosted on a specific IP.
        linkfromdomain: - Backlink Search: Finds links from a domain.
        contains:   - Embedded Content Search: Finds pages with specific files.
        related:    - Related Sites: Finds sites similar to a domain.
        """
    elif search_engine == "Google":
        help_message = """
        "           - Exact Phrase Search: Finds exact matches for a phrase.
        OR          - Logical OR: Finds pages with one of the specified words.
        AND         - Logical AND: Ensures all words appear in results.
        -           - Exclude Words: Excludes specified words.
        site:       - Site Search: Limits results to a domain.
        intitle:    - Title Keyword Search: Finds words in the title.
        inurl:      - URL Keyword Search: Finds words in the URL.
        allintitle: - All Terms in Title: Finds pages with all specified terms in the title.
        allinurl:   - All Terms in URL: Finds pages with all specified terms in the URL.
        intext:     - Body Text Search: Finds pages with terms in the text body.
        allintext:  - All Terms in Body: Finds pages with all terms in the text body.
        filetype:   - File Type Search: Limits results to specific file types (e.g., PDF).
        cache:      - Cached Version: Shows the cached version of a site.
        related:    - Related Sites: Finds sites related to a specified domain.
        info:       - Site Info: Provides information about a domain.
        link:       - Finds pages that link to a specified URL.
        define:     - Dictionary Search: Finds definitions for a specified term.
        numrange:   - Number Range: Searches within a range of numbers.
        before:     - Date Filter: Finds results published before a specific date.
        after:      - Date Filter: Finds results published after a specific date.
        """
    else:
        help_message = """
        1. site:        - Limits search results to a specific site or domain.
        2. intitle:     - Searches for pages with a specific word or phrase in the title.
        3. inurl:       - Searches for URLs containing a specific word or phrase.
        4. filetype:    - Searches for specific file types.
        5. intext:      - Searches for specific words within the text content of a webpage.
        6. link:        - Finds pages that link to a specific URL.
        """
    display_in_box(help_message)


def select_search_engine():
    search_message = """
[+] Which search engine are you using?
 1. Google
 2. Bing
 3. DuckDuckGo
 4. Yandex
"""
    display_in_box(search_message)
    
    choice = input("[+] Enter the number corresponding to your choice (1-4): ").strip()
    check_exit(choice)
    print("")
    
    search_engines = {
        '1': 'Google',
        '2': 'Bing',
        '3': 'DuckDuckGo',
        '4': 'Yandex'
    }
    
    return search_engines.get(choice, 'Google')

def select_operator(search_engine):
    operator_message = f"""
[+] Select the number corresponding to your operator of choice for {search_engine}:
[-] Type 'help' to display detailed explanations of each operator.
"""
    display_in_box(operator_message)
    
    operators = {
        '1': '+', '2': '-', '3': '""', '4': '*', '5': '|',
        '6': '~~', '7': '~', '8': '!', '9': 'url:', '10': 'site:', 
        '11': 'domain:', '12': 'title:', '13': 'mime:', '14': 'lang:', '15': 'date:' 
    } if search_engine == "Yandex" else {
        '1': '"', '2': 'OR', '3': 'AND', '4': 'NOT', '5': 'site:',
        '6': 'inurl:', '7': 'intitle:', '8': 'inanchor:', '9': 'filetype:', '10': 'inbody:',
        '11': 'feed:', '12': 'near:', '13': 'before:', '14': 'after:', '15': 'ip:', 
        '16': 'contains:', '17': 'related:', '18': 'hasfeed:', '19': 'loc:', '20': 'linkfromdomain:'
    } if search_engine == "Bing" else {
        '1': '"', '2': 'OR', '3': 'AND', '4': '-', '5': 'site:',
        '6': 'intitle:', '7': 'inurl:', '8': 'allintitle:', '9': 'allinurl:', '10': 'intext:',
        '11': 'allintext:', '12': 'filetype:', '13': 'cache:', '14': 'related:', '15': 'info:',
        '16': 'link:', '17': 'define:', '18': 'numrange:', '19': 'before:', '20': 'after:'
    }

    for key, op in operators.items():
        print(f"{key}. {op}")
    
    choice = input("\n[+] Enter the number corresponding to your operator of choice, or type 'help': ").strip()
    check_exit(choice)
    print("")  
    
    if choice.lower() == 'help':
        show_help_menu(search_engine)
        return select_operator(search_engine)
    elif choice in operators:
        return operators[choice]
    else:
        print("Invalid choice. Please select a valid operator number.\n")
        return select_operator(search_engine)

def get_search_phrase():
    phrase = input("[+] Enter the phrase to search for: ").strip()
    check_exit(phrase)
    print("")
    return phrase

def ask_to_add_additional_operator():
    while True:
        choice = input("[+] Would you like to add another operator? (yes/no): ").strip().lower()
        check_exit(choice)
        print("")  
        if choice in ['yes', 'no']:
            return choice == 'yes'

def ask_for_logical_operator():
    while True:
        logic_choice = input("[+] Do you want to use AND or OR to chain the operators? (AND/OR): ").strip().upper()
        check_exit(logic_choice)
        print("")  
        if logic_choice in ['AND', 'OR']:
            return logic_choice

def generate_search_dork():
    while True:
        display_welcome_message()

        search_engine = select_search_engine()
        dork_parts = []
        
        operator = select_operator(search_engine)
        phrase = get_search_phrase()
        dork_parts.append(f"{operator}{phrase}")
        
        while ask_to_add_additional_operator():
            logic_operator = ask_for_logical_operator()
            operator = select_operator(search_engine)
            phrase = get_search_phrase()
            dork_parts.append(f"{logic_operator} {operator}{phrase}")
        
        final_dork = " ".join(dork_parts)
        display_in_box(f"[+] Here is your generated search dork for {search_engine}:\n\n[-] {final_dork}")
        
        # Ask if user wants to create another dork 
	    again = input("\n[+] Would you like to generate another dork? (yes/no): ").strip().lower()
	    check_exit(again) 
	    print("") # Extra space for readability 
	    
	    if again != 'yes': 
	        print("\nThank you for using Gh0stD0rk Killer. Goodbye!") 
	        break 

if __name__ == "__main__": 
    generate_search_dork()
if __name__ == "__main__": 
    generate_search_dork()
