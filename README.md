# Nexus
PowerShell functions to query WolframAlpha, OpenAI GPT3 (DaVinci), and a few search engines (Google, DuckDuckGo, Kagi) from the PS terminal

           Bitpusher
            \`._,'/
            (_- -_)
              \o/
          The Digital
              Fox
 https://github.com/bitpusher2k

NexusQueries.ps1 - By Bitpusher/The Digital Fox
v1.1 last updated 2023-02-05
Simple functions to query various internet sources 
from the PowerShell command line via API/URL.

Currently supports:
Wolfram Alpha - e.g.: Ask-Wolfram "What is the largest city in California"
OpenAI DaVinci (GPT3) - e.g.: Ask-OpenAI "What are the top 3 Linux commands"
OpenAI images - e.g.: Ask-AIimage "A rocket ship taking off"
Google - e.g.: Ask-Google "How to use Google"
DuckDuckGo - e.g.: Ask-DDG "How to use DuckDuckGo"
Kagi - e.g.: Ask-Kagi "How to use Kagi"

Script will open a browser window of the Google/DuckDuckGo/Kagi search query. 
You must be signed in to use Kagi.
Choose the browser used for each search by name or path by modifying which
"Start-Process" line is used by each search function. 
