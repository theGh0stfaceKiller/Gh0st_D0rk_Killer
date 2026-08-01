#Requires -Version 5.1
<#
.SYNOPSIS
    IndieDork - PowerShell Edition
    A True Indie tool
    For ethical hackers, OSINT investigators, and cybersecurity researchers.

.DESCRIPTION
    Advanced dork generator for Google, Bing, DuckDuckGo, Yandex,
    Twitter, Bluesky, and Shodan. Supports templates, nested operators,
    auto-save, timed generation, CLI args, and Shodan API integration.

.PARAMETER Engine
    Search engine to target.

.PARAMETER Dork
    Dork string to format/output directly.

.PARAMETER Format
    Output format: plain, url, or json.

.PARAMETER Save
    Save the dork to file.

.PARAMETER Template
    Run a pre-built template by number (1-10).

.PARAMETER Shodan
    Run a Shodan query string directly.

.PARAMETER Timed
    Run timed dork generation mode.

.EXAMPLE
    .\indiedork.ps1
    .\indiedork.ps1 -Engine Google -Dork 'site:example.com filetype:pdf' -Format url
    .\indiedork.ps1 -Template 1 -Save
    .\indiedork.ps1 -Shodan 'port:3389 os:Windows'
#>

[CmdletBinding()]
param(
    [string]$Engine   = "",
    [string]$Dork     = "",
    [ValidateSet("plain","url","json")]
    [string]$Format   = "",
    [switch]$Save,
    [string]$Template = "",
    [string]$Shodan   = "",
    [switch]$Timed
)

# ── Settings ──────────────────────────────────────────────────
$SettingsFile = Join-Path $HOME ".indiedork_settings.json"
$DorksFile    = "saved_dorks.txt"

$DefaultSettings = @{
    DefaultEngine = "Google"
    AutoSave      = $false
    OutputFormat  = "plain"
    ShodanApiKey  = ""
}

function Load-Settings {
    if (Test-Path $SettingsFile) {
        try {
            $s = Get-Content $SettingsFile -Raw | ConvertFrom-Json
            $settings = $DefaultSettings.Clone()
            foreach ($key in $s.PSObject.Properties.Name) {
                $settings[$key] = $s.$key
            }
            return $settings
        } catch {
            return $DefaultSettings.Clone()
        }
    }
    return $DefaultSettings.Clone()
}

function Save-IndieDorkSettings($settings) {
    $settings | ConvertTo-Json | Set-Content $SettingsFile
}

$Settings = Load-Settings

# ── Operators ─────────────────────────────────────────────────
$AllOperators = @{
    Google = [ordered]@{
        "1"="site:"; "2"="intitle:"; "3"="inurl:"; "4"="filetype:"
        "5"="intext:"; "6"="link:"; "7"="cache:"; "8"="related:"
        "9"="allintitle:"; "10"="allinurl:"; "11"="allintext:"
        "12"="before:"; "13"="after:"; "14"="define:"
        "15"="OR"; "16"="AND"; "17"="-"; "18"='"'
    }
    Bing = [ordered]@{
        "1"="site:"; "2"="intitle:"; "3"="inurl:"; "4"="filetype:"
        "5"="inbody:"; "6"="inanchor:"; "7"="contains:"; "8"="feed:"
        "9"="hasfeed:"; "10"="ip:"; "11"="loc:"; "12"="before:"
        "13"="after:"; "14"="near:"; "15"="OR"; "16"="AND"; "17"="NOT"
    }
    DuckDuckGo = [ordered]@{
        "1"="site:"; "2"="intitle:"; "3"="inurl:"; "4"="filetype:"
        "5"="intext:"; "6"="-"; "7"='"'; "8"="OR"
    }
    Yandex = [ordered]@{
        "1"="site:"; "2"="url:"; "3"="title:"; "4"="mime:"
        "5"="lang:"; "6"="date:"; "7"="+"; "8"="-"
        "9"='""'; "10"="*"; "11"="|"; "12"="&"
    }
    Twitter = [ordered]@{
        "1"="from:"; "2"="to:"; "3"="lang:"; "4"="since:"
        "5"="until:"; "6"="min_replies:"; "7"="min_faves:"
        "8"="min_retweets:"; "9"="filter:links"; "10"="-"
        "11"='"'; "12"="#"
    }
    Bluesky = [ordered]@{
        "1"="from:"; "2"="to:"; "3"="mentions:"; "4"="domain:"
        "5"="since:"; "6"="until:"; "7"="lang:"; "8"="#"; "9"="@"; "10"='"'
    }
    Shodan = [ordered]@{
        "1"="ip:"; "2"="port:"; "3"="org:"; "4"="country:"; "5"="city:"
        "6"="hostname:"; "7"="product:"; "8"="os:"; "9"="net:"
        "10"="asn:"; "11"="ssl:"; "12"="http.title:"
        "13"="http.html:"; "14"="vuln:"; "15"="has_screenshot:"
    }
}

$HelpText = @{
    Google = @"
  site:        Restrict to domain.
  intitle:     Keyword in title.
  inurl:       Keyword in URL.
  filetype:    File type filter (pdf, xls, etc).
  intext:      Keyword in body text.
  cache:       Cached version.
  related:     Related sites.
  before/after: Date filters (YYYY-MM-DD).
  OR / AND / - : Logic operators.
"@
    Shodan = @"
  Requires your own Shodan API key (set in Settings).
  ip:          Search by IP address.
  port:        Open port filter.
  org:         Organization / ISP.
  country:     Two-letter country code.
  city:        City name.
  hostname:    Match in hostname.
  product:     Software product name.
  os:          Operating system.
  net:         CIDR range.
  vuln:        CVE identifier.
  http.title:  HTTP page title.
"@
}

$EngineBaseUrls = @{
    Google     = "https://www.google.com/search?q="
    Bing       = "https://www.bing.com/search?q="
    DuckDuckGo = "https://duckduckgo.com/?q="
    Yandex     = "https://yandex.com/search/?text="
    Twitter    = "https://twitter.com/search?q="
    Bluesky    = "https://bsky.app/search?q="
    Shodan     = "https://www.shodan.io/search?query="
}

# ── Pre-built templates ───────────────────────────────────────
# NOTE: Templates 5, 6, 7, and 9 return real, live results against
# real systems. Only run these against assets you own or have
# explicit written authorization to test.
$Templates = [ordered]@{
    "1"  = @{ Name="Exposed Login Pages";         Engine="Google";  Dork='intitle:"login" OR intitle:"admin" inurl:login filetype:php' }
    "2"  = @{ Name="Open Directory Listing";      Engine="Google";  Dork='intitle:"index of /" intext:"parent directory"' }
    "3"  = @{ Name="Exposed Config Files";        Engine="Google";  Dork='filetype:env OR filetype:cfg intext:"password"' }
    "4"  = @{ Name="SQL Errors";                  Engine="Google";  Dork='intext:"sql syntax near" OR intext:"mysql_fetch"' }
    "5"  = @{ Name="Exposed Camera Feeds";        Engine="Google";  Dork='inurl:"/view/index.shtml" OR intitle:"Live View / - AXIS"' }
    "6"  = @{ Name="Shodan: Open RDP";            Engine="Shodan";  Dork='port:3389 os:"Windows"' }
    "7"  = @{ Name="Shodan: Default Credentials"; Engine="Shodan";  Dork='http.title:"Welcome" port:80 product:"Apache"' }
    "8"  = @{ Name="Pastebin Leaks";              Engine="Google";  Dork='site:pastebin.com intext:"password" OR intext:"api_key"' }
    "9"  = @{ Name="Exposed AWS Keys";            Engine="Google";  Dork='filetype:txt intext:"AKIA" intext:"SECRET"' }
    "10" = @{ Name="Twitter OSINT - Target";      Engine="Twitter"; Dork='from:TARGET since:2024-01-01 until:2025-01-01' }
}

# ── Helpers ───────────────────────────────────────────────────
function Show-Box($text) {
    $width = 91
    Write-Host ("`n+" + ("-" * $width) + "+")
    foreach ($line in $text -split "`n") {
        Write-Host ("| " + $line.PadRight($width) + " |")
    }
    Write-Host ("+" + ("-" * $width) + "+`n")
}

function Show-Banner {
    $logo = @'

'@
    $box_w = 50
    Write-Host ("`n+" + ("-" * $box_w) + "+")
    foreach ($line in $logo -split "`n") {
        Write-Host ("| " + $line.PadRight($box_w) + " |") -ForegroundColor DarkRed
    }
    foreach ($line in @(
        "",
        "  IndieDork  |  A True Indie Tool",
        "  OSINT | Ethical Hacking | Security Research",
        "  Type 'exit' at any prompt to quit.",
        ""
    )) {
        Write-Host ("| " + $line.PadRight($box_w) + " |")
    }
    Write-Host ("+" + ("-" * $box_w) + "+`n")
}

function Check-Exit($val) {
    if ($val.Trim().ToLower() -eq "exit") {
        Write-Host "`nExiting. Goodbye."
        exit 0
    }
}

function Ask($msg) {
    $val = Read-Host $msg
    Check-Exit $val
    return $val.Trim()
}

function UrlEncode($str) {
    return [System.Uri]::EscapeDataString($str)
}

# ── Output formatting ─────────────────────────────────────────
function Format-Dork($dork, $engine, $fmt) {
    $base = $EngineBaseUrls[$engine]
    $url  = $base + (UrlEncode $dork)
    switch ($fmt) {
        "url"  { return $url }
        "json" {
            return @{engine=$engine; dork=$dork; url=$url; timestamp=(Get-Date -Format "yyyy-MM-dd HH:mm:ss")} |
                   ConvertTo-Json -Compress
        }
        default { return $dork }
    }
}

function Print-Dork($dork, $engine) {
    $fmt = $Settings.OutputFormat
    $base = $EngineBaseUrls[$engine]
    $url  = $base + (UrlEncode $dork)
    Show-Box "[+] Dork for ${engine}:`n`n    $dork`n`n[URL] $url"
    if ($fmt -eq "json") {
        Write-Host (Format-Dork $dork $engine "json")
    }
}

# ── Save ──────────────────────────────────────────────────────
function Save-Dork($dork, $engine) {
    $ts   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$engine] $dork"
    Add-Content -Path $DorksFile -Value $line
    Write-Host "[+] Saved to $DorksFile"
}

function View-SavedDorks {
    if (Test-Path $DorksFile) {
        Get-Content $DorksFile
    } else {
        Write-Host "[-] No saved dorks found."
    }
}

# ── Shodan ────────────────────────────────────────────────────
function Invoke-ShodanQuery($query) {
    $key = $Settings.ShodanApiKey
    if (-not $key) {
        Write-Host "[-] Shodan API key not set. Go to Settings."
        return
    }
    $encoded = UrlEncode $query
    $url     = "https://api.shodan.io/shodan/host/search?key=${key}&query=${encoded}"
    Write-Host "[+] Querying Shodan: $query`n"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10
        Write-Host "[+] Total results: $($response.total)"
        foreach ($match in $response.matches | Select-Object -First 5) {
            Write-Host ("  $($match.ip_str):$($match.port)  |  $($match.org)  |  $($match.product)")
        }
        Write-Host ""
    } catch {
        Write-Host "[-] Shodan query failed: $_"
    }
}

# ── Operator selection ────────────────────────────────────────
function Show-Operators($engine) {
    $ops = $AllOperators[$engine]
    foreach ($k in $ops.Keys) {
        Write-Host ("  {0}. {1}" -f $k, $ops[$k])
    }
}

function Select-Operator($engine) {
    $ops = $AllOperators[$engine]
    Show-Operators $engine
    $choice = Ask "[+] Enter operator number (or 'help')"
    if ($choice.ToLower() -eq "help") {
        $help = $HelpText[$engine]
        if ($help) { Show-Box $help } else { Write-Host "[-] No help for $engine." }
        return Select-Operator $engine
    }
    if ($ops.Contains($choice)) {
        return $ops[$choice]
    }
    Write-Host "[-] Invalid operator."
    return Select-Operator $engine
}

function Suggest-Operators($engine, $used) {
    $ops   = $AllOperators[$engine].Values | Where-Object { $_ -notin $used } | Select-Object -First 3
    if ($ops) { Write-Host ("[~] Suggestions: {0}`n" -f ($ops -join ", ")) }
}

# ── Build dork ────────────────────────────────────────────────
function Build-NestedGroup($engine) {
    Show-Box "[+] Nested Group Builder`n  Operators here are wrapped in parentheses."
    $parts = @()
    while ($true) {
        $op     = Select-Operator $engine
        $phrase = Ask "[+] Value for '$op'"
        $parts += "${op}${phrase}"
        $more = Ask "[+] Add another to this group? (yes/no)"
        if ($more.ToLower() -ne "yes") { break }
    }
    return "(" + ($parts -join " ") + ")"
}

function Build-Dork($engine) {
    $parts   = @()
    $usedOps = @()

    $op     = Select-Operator $engine
    $phrase = Ask "[+] Value for '$op'"
    $parts += "${op}${phrase}"
    $usedOps += $op

    while ($true) {
        Suggest-Operators $engine $usedOps
        $more = Ask "[+] Add operator? (yes/no/nested)"
        switch ($more.ToLower()) {
            "no" { return $parts -join "" }
            "yes" {
                $logic = (Ask "[+] Chain with AND/OR (or blank)").ToUpper()
                $op     = Select-Operator $engine
                $phrase = Ask "[+] Value for '$op'"
                $connector = if ($logic -in @("AND","OR")) { " $logic " } else { " " }
                $parts   += "${connector}${op}${phrase}"
                $usedOps += $op
            }
            "nested" {
                $logic = (Ask "[+] Chain with AND/OR (or blank)").ToUpper()
                $group = Build-NestedGroup $engine
                $connector = if ($logic -in @("AND","OR")) { " $logic " } else { " " }
                $parts += "${connector}${group}"
            }
            default { Write-Host "[-] Enter yes, no, or nested." }
        }
    }
}

# ── Timed mode ────────────────────────────────────────────────
function Start-TimedMode {
    Show-Box "[+] Timed Dork Mode`n  Cycles through templates. Press Ctrl+C to stop."
    $interval = [int](Ask "[+] Interval in seconds")
    $keys     = $Templates.Keys | Sort-Object
    $idx      = 0
    try {
        while ($true) {
            $k      = @($keys)[$idx % $keys.Count]
            $tpl    = $Templates[$k]
            $ts     = Get-Date -Format "HH:mm:ss"
            Write-Host "[$ts] [$($tpl.Engine)] $($tpl.Name)"
            Write-Host "    $($tpl.Dork)"
            if ($Settings.AutoSave) { Save-Dork $tpl.Dork $tpl.Engine }
            $idx++
            Start-Sleep -Seconds $interval
        }
    } catch {
        Write-Host "`n[+] Timed mode stopped."
    }
}

# ── Templates ─────────────────────────────────────────────────
function Show-TemplateMenu {
    Show-Box "[+] Pre-Built Templates"
    foreach ($k in $Templates.Keys) {
        $t = $Templates[$k]
        Write-Host ("  $k. [$($t.Engine)] $($t.Name)")
        Write-Host ("      $($t.Dork)`n")
    }
    $choice = Ask "[+] Enter template number (or 'back')"
    if ($choice.ToLower() -eq "back") { return }
    $tpl = $Templates[$choice]
    if (-not $tpl) { Write-Host "[-] Invalid selection."; return }
    Print-Dork $tpl.Dork $tpl.Engine
    $sv = Ask "[+] Save this dork? (yes/no)"
    if ($sv.ToLower() -eq "yes") { Save-Dork $tpl.Dork $tpl.Engine }
    if ($tpl.Engine -eq "Shodan") {
        $run = Ask "[+] Run Shodan query now? (yes/no)"
        if ($run.ToLower() -eq "yes") { Invoke-ShodanQuery $tpl.Dork }
    }
}

# ── Settings ──────────────────────────────────────────────────
function Show-SettingsMenu {
    while ($true) {
        $keyStatus = if ($Settings.ShodanApiKey) { "SET" } else { "NOT SET" }
        Show-Box "[+] Settings
  1. Default engine  : $($Settings.DefaultEngine)
  2. Auto-save       : $($Settings.AutoSave)
  3. Output format   : $($Settings.OutputFormat)  (plain | url | json)
  4. Shodan API key  : $keyStatus
  5. Back"

        $choice = Ask "[+] Choose setting (1-5)"
        switch ($choice) {
            "1" {
                $engines = $AllOperators.Keys | Sort-Object
                $i = 1; foreach ($e in $engines) { Write-Host "  $i. $e"; $i++ }
                $sel = [int](Ask "[+] Enter number") - 1
                $arr = @($engines)
                if ($sel -ge 0 -and $sel -lt $arr.Count) {
                    $Settings.DefaultEngine = $arr[$sel]
                }
            }
            "2" { $Settings.AutoSave = -not $Settings.AutoSave }
            "3" {
                $fmt = Ask "[+] Format (plain/url/json)"
                if ($fmt -in @("plain","url","json")) {
                    $Settings.OutputFormat = $fmt
                } else { Write-Host "[-] Invalid format." }
            }
            "4" {
                $key = Ask "[+] Enter Shodan API key (blank to clear)"
                $Settings.ShodanApiKey = $key
            }
            "5" { return }
            default { Write-Host "[-] Invalid option." }
        }
        Save-IndieDorkSettings $Settings
        Write-Host "[+] Settings saved."
    }
}

# ── Engine selection ──────────────────────────────────────────
function Select-Engine {
    $engines = @($AllOperators.Keys | Sort-Object)
    Show-Box "[+] Select Search Engine  (default: $($Settings.DefaultEngine))"
    $i = 1
    foreach ($e in $engines) { Write-Host "  $i. $e"; $i++ }
    $choice = Ask "[+] Enter number (or Enter for default)"
    if ($choice -eq "") { return $Settings.DefaultEngine }
    $idx = [int]$choice - 1
    if ($idx -ge 0 -and $idx -lt $engines.Count) { return $engines[$idx] }
    Write-Host "[-] Invalid, using default."
    return $Settings.DefaultEngine
}

# ── CLI handling ──────────────────────────────────────────────
function Handle-CLI {
    if ($Format) { $Settings.OutputFormat = $Format }

    if ($Timed) { Start-TimedMode; exit 0 }

    if ($Shodan) { Invoke-ShodanQuery $Shodan; exit 0 }

    if ($Template) {
        $tpl = $Templates[$Template]
        if (-not $tpl) { Write-Host "[-] Template not found."; exit 1 }
        Print-Dork $tpl.Dork $tpl.Engine
        if ($Save) { Save-Dork $tpl.Dork $tpl.Engine }
        exit 0
    }

    if ($Dork -and $Engine) {
        Print-Dork $Dork $Engine
        if ($Save) { Save-Dork $Dork $Engine }
        exit 0
    }
}

# ── Main ──────────────────────────────────────────────────────
# Run CLI mode if meaningful args were passed
$cliMode = $Engine -or $Dork -or $Template -or $Shodan -or $Timed
if ($cliMode) { Handle-CLI }

Show-Banner

while ($true) {
    Show-Box "[+] Main Menu
  1. Build a dork
  2. Use a template
  3. View saved dorks
  4. Timed dork generation
  5. Shodan query
  6. Settings
  7. Exit"

    $choice = Ask "[+] Choose (1-7)"
    switch ($choice) {
        "1" {
            $engine = Select-Engine
            $dork   = Build-Dork $engine
            Print-Dork $dork $engine
            if ($Settings.AutoSave) {
                Save-Dork $dork $engine
            } else {
                $sv = Ask "[+] Save this dork? (yes/no)"
                if ($sv.ToLower() -eq "yes") { Save-Dork $dork $engine }
            }
            if ($engine -eq "Shodan") {
                $run = Ask "[+] Run Shodan query now? (yes/no)"
                if ($run.ToLower() -eq "yes") { Invoke-ShodanQuery $dork }
            }
        }
        "2" { Show-TemplateMenu }
        "3" { View-SavedDorks }
        "4" { Start-TimedMode }
        "5" {
            $q = Ask "[+] Enter Shodan query"
            Invoke-ShodanQuery $q
        }
        "6" { Show-SettingsMenu }
        "7" {
            Write-Host "`nThank you for using IndieDork. Goodbye.`n"
            exit 0
        }
        default { Write-Host "[-] Invalid option." }
    }
}
