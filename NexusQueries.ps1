#           Bitpusher
#            \`._,'/
#            (_- -_)
#              \o/
#          The Digital
#              Fox
# https://github.com/bitpusher2k
#
# NexusQueries.ps1 - By Bitpusher/The Digital Fox
# v1.1 last updated 2023-02-05
# Simple functions to query various internet sources 
# from the PowerShell command line via API/URL.
#
# "Set the Nexus free at last"...
# https://www.youtube.com/watch?v=SxOybZcRXhI
#
# Currently supports:
# Wolfram Alpha - e.g.: Ask-Wolfram "What is the largest city in California"
# OpenAI DaVinci (GPT3) - e.g.: Ask-OpenAI "What are the top 3 Linux commands"
# OpenAI images - e.g.: Ask-AIimage "A rocket ship taking off"
# Google - e.g.: Ask-Google "How to use Google"
# DuckDuckGo - e.g.: Ask-DDG "How to use DuckDuckGo"
# Kagi - e.g.: Ask-Kagi "How to use Kagi"
#
# Script will open a browser window of the Google/DuckDuckGo/Kagi search query. 
# You must be signed in to use Kagi.
# Choose the browser used for each search by name or path by modifying which
# "Start-Process" line is used by each search function. 
#
# Add your WolframAlpha API key to line 56 - https://developer.wolframalpha.com/portal/myapps/index.html
# Add your OpanAI API key to lines 86 & 130 - https://platform.openai.com/account/api-keys
#
# Dot-source this script to have these functions at your fingertips for the session:
# . .\NexusQueries.ps1
#
# To load these functions every time PowerShell is started, check where the
# CurrentUserCurrentHost profile is located with this command:
# foreach ($profileLocation in ($PROFILE | Ask-Member -MemberType NoteProperty).Name) {Write-Host "$($profileLocation): $($PROFILE.$profileLocation)"}
# Likely the location is something like:
# %UserProfile%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# And add a line in your profile to dot-source the full path to this script. e.g.:
# . C:\Users\Username\Documents\PowerShell\NexusQueries.ps1

Function Ask-Wolfram {
    [CmdLetBinding()]
    Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question,
	#API key is here in plain text. Could be stashed as a secret with the 
	#Microsoft.PowerShell.SecretManagement module & retrieved with something like:
    #[String]$apiKey = (Get-Secret -Name WolframAlphaAPI | ConvertFrom-SecureString -AsPlainText),
    [String]$apiKey = 'XXXXXXXX'
    )

    #API docs - https://products.wolframalpha.com/short-answers-api/documentation/
    begin {
        $apiEndpoint = "http://api.wolframalpha.com/v1/result"
    }
    
    process {
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($Question)
        $url = "$apiEndpoint`?appid=$apiKey&i=$encodedQuery"
        $response = Invoke-RestMethod -Uri $url -Method Get
        $response
    }
    
    end {
    }
}

function Ask-OpenAI {
    [CmdLetBinding()]
    param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question,
	#API key is here in plain text. Could be stashed as a secret with the 
	#Microsoft.PowerShell.SecretManagement module & retrieved with something like:
    #[String]$apiKey = (Get-Secret -Name ChatGptAPI | ConvertFrom-SecureString -AsPlainText),
    [String]$apiKey = "XXXXXXXX",
    [ValidateSet("text-davinci-003", "code-cushman-001", "code-davinci-001")]
    [String]$model = "text-davinci-003",
    [int]$maxtokens = 4000,
    [ValidateRange(0,1)]
    [int]$temperature = 0.5
    )

    begin {
        $apiEndpoint = "https://api.openai.com/v1/completions"
    }
    
    process {
        # Set the request headers
        $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $apiKey"
        }   
        # Set the request body
        $requestBody = @{
            "prompt" = $Question
            "model" = $model
            "max_tokens" = $maxtokens
            "temperature" = $temperature
        }
        $response = Invoke-RestMethod -Method POST -Uri $apiEndpoint -Headers $headers -Body (ConvertTo-Json $requestBody)
        $response.choices.text
    }

    end {
    }
}

function Ask-AIimage {
    [CmdLetBinding()]
    param (
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question,
	#API key is here in plain text. Could be stashed as a secret with the 
	#Microsoft.PowerShell.SecretManagement module & retrieved with something like:
    #[String]$apiKey = (Get-Secret -Name ChatGptAPI | ConvertFrom-SecureString -AsPlainText),
    [String]$apiKey = "XXXXXXXX",
    [Validaterange(1,10)]
    [int]$number = 1,
    [ValidateSet("256x256","512x512","1024x1024")]
    [String]$size = "512x512",
    [ValidateSet('url','b64_json')]
    [string]$responseFormat = 'url'
    )

    begin {
        $apiEndpoint = "https://api.openai.com/v1/images/generations"
    }
    
    process {
        # Set the request headers
        $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $apiKey"
        }   
        # Set the request body
        $requestBody = @{
            "prompt" = $Question
            "n" = $number
            "size" = $size
            "response_format" = $responseFormat
        }
        $response = Invoke-RestMethod -Method POST -Uri $apiEndpoint -Headers $headers -Body (ConvertTo-Json $requestBody)
        $response.data.url
    }

    end {
    }
}

function Ask-Google { 
    [CmdLetBinding()]
    Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question
    )

    Begin { 
        $query='https://www.google.com/search?q=' 
        } 

    Process { 
        $Question = $Question -replace '\s','+'
        $query = $query + $Question
    } 

    End { 
        $url = $query 
        "Google search query will be $url `nInvoking..." 
        Start-Process "$url" #Open search in default browser
        # Start-Process chrome "$url" #Open search in Chrome
        # Start-Process firefox "$url" #Open search in Firefox
        # Start-Process msedge "$url" #Open search in Edge
        # Start-Process -FilePath "C:\Users\FirefoxPortableDeveloper\FirefoxPortable.exe" -ArgumentList "$url" #Open search in specific browser by path
    } 
}

function Ask-DDG { 
    [CmdLetBinding()]
    Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question
    )

    Begin { 
        $query='https://duckduckgo.com/?q=' 
        } 

    Process { 
        $Question = $Question -replace '\s','+'
        $query = $query + $Question
    } 

    End { 
        $url = $query 
        "DDG search query will be $url `nInvoking..." 
        # Start-Process "$url" #Open search in default browser
        Start-Process chrome "$url" #Open search in Chrome
        # Start-Process firefox "$url" #Open search in Firefox
        # Start-Process msedge "$url" #Open search in Edge
        # Start-Process -FilePath "C:\Users\FirefoxPortableDeveloper\FirefoxPortable.exe" -ArgumentList "$url" #Open search in specific browser by path
    } 
}

function Ask-Kagi { 
    [CmdLetBinding()]
    Param(
    [ValidateNotNullOrEmpty()]
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $true
        )]
    [String]$Question
    )

    Begin { 
        $query='https://kagi.com/search?q=' 
        } 

    Process { 
        $Question = $Question -replace '\s','+'
        $query = $query + $Question
    } 

    End { 
        $url = $query 
        "Kagi search query will be $url `nInvoking..." 
        # Start-Process "$url" #Open search in default browser
        Start-Process chrome "$url" #Open search in Chrome
        # Start-Process firefox "$url" #Open search in Firefox
        # Start-Process msedge "$url" #Open search in Edge
        # Start-Process -FilePath "C:\Users\FirefoxPortableDeveloper\FirefoxPortable.exe" -ArgumentList "$url" #Open search in specific browser by path
    } 
}

#This version of the function takes multiple input parameters & merges them into one search query so you don't have to use quotes.
#function Ask-DDG { 
#   Begin { 
#       $query='https://duckduckgo.com/?q=' 
#       } 
#
#   Process { 
#       if ($args.Count -eq 0) {
#           "Arguments empty - commiting `$input to `$args" 
#           Set-Variable -Name args -Value (@($input) | % {$_}) 
#           "Arguments now equal $args"
#           $args = $args.Split() 
#       }
#       else { 
#           "Arguments set - Using them" 
#       }
#       Write-Host $args.Count, "Argument(s) detected" "Parsing out Arguments: $args"
#       for ($i=0; $i -lt $args.Count; $i++){
#           "Arg $i `t $($args[$i]) `t Length `t" + $args[$i].Length, " characters"
#       }
#       $args | % {$query = $query + "$_+"}
#   } 
#
#   End { 
#       $url = $query.Substring(0,$query.Length-1) 
#       "Final Search will be $url `nInvoking..." 
#       start "$url" 
#   } 
#}
