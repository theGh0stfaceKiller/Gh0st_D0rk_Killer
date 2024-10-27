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
2. **Usage**:
```bash
   sudo python GDK.py
```
