def display_welcome_message():
    print("""
    
+-------------------------------------------------------------------------------------------+
|                                                                                           |
|              ('-. .-.            .-')   .-') _   _ .-') _            _  .-')  .-. .-')    |
|             ( xx )  /           ( xx ).(  xx) ) ( (  xx) )          ( \( xx ) \  ( xx )   |
|    ,----.   ,--. ,--.  .----.  (_)---\_)     '._ \     .'_   .----.  ,------. ,--. ,--.   |
|   '  .-./-')|  | |  | /  ..  \ /    _ ||'--...__),`'--..._) /  ..  \ |   /`. '|  .'   /   |
|   |  |_( xx )   .|  |.  /  \  .\  :` `.'--.  .--'|  |  \  '.  /  \  .|  /  | ||      /,   |
|   |  | .--, \       ||  |  '  | '..`''.)  |  |   |  |   ' ||  |  '  ||  |_.' ||     ' _)  |
|  (|  | '. (_/  .-.  |'  \  /  '.-._)   \  |  |   |  |   / :'  \  /  '|  .  '.'|  .   \    |
|   |  '--'  ||  | |  | \  `'  / \       /  |  |   |  '--'  / \  `'  / |  |\  \ |  |\   \   |
|    `------' `--' `--'  `---''   `-----'   `--'   `-------'   `---''  `--' '--'`--' '--'   |
|  .-. .-')                               ('-.  _  .-')                                     |
|  \  ( xx )                            _(  xx)( \( xx )                                    |
|  ,--. ,--. ,-.-')  ,--.      ,--.    (,------.,------.                                    |
|  |  .'   / |  |xx) |  |.-')  |  |.-') |  .---'|   /`. '                                   |
|  |      /, |  |  \ |  | xx ) |  | xx )|  |    |  /  | |                                   |
|  |     ' _)|  |(_/ |  |`-' | |  |`-' (|  '--. |  |_.' |                                   |
|  |  .   \ ,|  |_.'(|  '---.'(|  '---.'|  .--' |  .  '.'                                   |
|  |  |\   (_|  |    |      |  |      | |  `---.|  |\  \                                    |
|  `--' '--' `--'    `------'  `------' `------'`--' '--'                                   |
|                                                                                           |
+-------------------------------------------------------------------------------------------+        
    
    Created by: The_Gh0stface_Killer
    
    This script will help you generate dorks for search engines like Google, Bing, DuckDuckGo, and Yandex.
    Advanced operators will help you refine your search.

    """)


def show_help_menu(search_engine):
    print("\n------------------------------------------")
    print("Help Menu - Search Operator Descriptions")
    print("------------------------------------------")
    
    if search_engine == "Yandex":
        print("""
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
        /(x y) - Groups terms with position.
        ()    - Grouping of terms.
        url:  - Search within a specific URL.
        inurl: - Search for terms within the URL.
        site:  - Search within a specific site or domain.
        domain: - Search within a main domain only.
        host:  - Limits results to a specific host.
        rhost: - Search results excluding host.
        title: - Limits results to pages with keywords in the title.
        mime:  - Search specific MIME types.
        lang:  - Filter by language.
        date:  - Filter by date.
        $ anchor() - Anchored search.
        """)
    else:
        print("""
        1. site:        - Limits search results to a specific site or domain (e.g., site:example.com).
        2. intitle:     - Searches for pages with a specific word or phrase in the title (e.g., intitle:login).
        3. inurl:       - Searches for URLs containing a specific word or phrase (e.g., inurl:admin).
        4. filetype:    - Searches for specific file types (e.g., filetype:pdf to find PDF files).
        5. intext:      - Searches for specific words within the text content of a webpage (e.g., intext:"data leak").
        6. link:        - Finds pages that link to a specific URL (e.g., link:example.com).
        """)

    print("------------------------------------------")

def select_search_engine():
    print("\n[+] Which search engine are you using?")
    print(" 1. Google")
    print(" 2. Bing")
    print(" 3. DuckDuckGo")
    print(" 4. Yandex")
    print("")
    
    search_engines = {
        '1': 'Google',
        '2': 'Bing',
        '3': 'DuckDuckGo',
        '4': 'Yandex'
    }
    
    choice = input("[+] Enter the number corresponding to your choice (1-4): ").strip()
    return search_engines.get(choice, 'Google')  # Default to Google if invalid choice

def select_operator(search_engine):
    print(f"\n[+] Select the number corresponding to your operator of choice for {search_engine}:")
    print("")
    print("[-] Type 'help' to display detailed explanations of each operator.\n")
    
    # Define operators based on search engine
    if search_engine == "Yandex":
        operators = {
            '1': '+',        
            '2': '-',        
            '3': '""',       
            '4': '*',        
            '5': '|',        
            '6': '~~',       
            '7': '~',        
            '8': '!',        
            '9': 'url:',     
            '10': 'site:',   
            '11': 'domain:', 
            '12': 'title:',  
            '13': 'mime:',   
            '14': 'lang:',   
            '15': 'date:'    
        }
    else:
        operators = {
            '1': 'site:',        
            '2': 'intitle:',     
            '3': 'inurl:',       
            '4': 'filetype:',    
            '5': 'intext:',      
            '6': 'link:'         
        }

    # Display operator options
    for key, op in operators.items():
        print(f"{key}. {op}")
    
    # Get user choice with error handling
    choice = input("[+] Enter the number corresponding to your operator of choice, or type 'help': ").strip()
    
    if choice.lower() == 'help':
        show_help_menu(search_engine)
        return select_operator(search_engine)  # Recursively call to select again after showing help
    elif choice in operators:
        return operators[choice]  # Return valid choice from user
    else:
        print("Invalid choice. Please select a valid operator number.")
        return select_operator(search_engine)  # Retry on invalid selection

def get_search_phrase():
    return input("[+] Enter the phrase to search for: ").strip()

def ask_to_add_additional_operator():
    while True:
        choice = input("[+] Would you like to add another operator? (yes/no): ").strip().lower()
        if choice in ['yes', 'no']:
            return choice == 'yes'

def ask_for_logical_operator():
    while True:
        logic_choice = input("[+] Do you want to use AND or OR to chain the operators? (AND/OR): ").strip().upper()
        if logic_choice in ['AND', 'OR']:
            return logic_choice

def generate_search_dork():
    display_welcome_message()

    # Step 1: Select search engine
    search_engine = select_search_engine()

    # Step 2: Select the first operator
    dork_parts = []
    
    operator = select_operator(search_engine)
    phrase = get_search_phrase()
    dork_parts.append(f"{operator}{phrase}")
    
    # Step 3: Add more operators if user desires
    while ask_to_add_additional_operator():
        logic_operator = ask_for_logical_operator()
        operator = select_operator(search_engine)
        phrase = get_search_phrase()
        dork_parts.append(f"{logic_operator} {operator}{phrase}")
    
    # Final dork construction
    final_dork = " ".join(dork_parts)
    
    print(f"\n[+] Here is your generated search dork for {search_engine}:")
    print(f"\n[-] {final_dork}")
    
    print("\n**Copy and paste the dork into your browser to perform the search.**")

if __name__ == "__main__":
    generate_search_dork()