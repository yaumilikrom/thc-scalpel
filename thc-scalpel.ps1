#Requires -Version 5.1

<#
.SYNOPSIS
    THC Scalpel Tool - PowerShell Edition
    
.DESCRIPTION
Automation of intelligence through ip.thc.org for Red Team operations
    Support for reverse DNS, subdomain search, CNAME lookup

.PARAMETER Target
    Target IP, domain, or subnet

.PARAMETER Type
    Type of intelligence: rdns, subdomain, cname, subnet

.PARAMETER InputFile
    A file with a list of goals

.PARAMETER OutputFile
    A file for saving the results

.PARAMETER Delay
    Delay between requests (seconds)

.PARAMETER Threads
    Number of parallel threads

.PARAMETER Keywords
    Keywords for filtering (separated by commas)

.EXAMPLE
    .\thc-scalpel.ps1 -Target "140.82.121.3" -Type rdns

.EXAMPLE
    .\thc-scalpel.ps1 -Target "example.com" -Type subdomain -OutputFile results.json

.EXAMPLE
    .\thc-scalpel.ps1 -InputFile targets.txt -Type rdns -Delay 1 -Threads 3

.NOTES
    For authorized testing only
    Author: Hackteam.Red (KL3FT3Z (https://github.com/toxy4ny))
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Target,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('rdns', 'subdomain', 'cname', 'subnet')]
    [string]$Type = 'rdns',
    
    [Parameter(Mandatory=$false)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$false)]
    [double]$Delay = 0.5,
    
    [Parameter(Mandatory=$false)]
    [int]$Threads = 5,
    
    [Parameter(Mandatory=$false)]
    [string]$Keywords,
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 30,
    
    [Parameter(Mandatory=$false)]
    [switch]$Stealth,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$script:BaseUrl = "https://ip.thc.org"
$script:UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
$script:Results = @{}

$script:Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
}


function Write-Info {
    param([string]$Message)
    Write-Host "[*] $Message" -ForegroundColor $script:Colors.Info
}

function Write-Success {
    param([string]$Message)
    Write-Host "[+] $Message" -ForegroundColor $script:Colors.Success
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor $script:Colors.Warning
}

function Write-Error {
    param([string]$Message)
    Write-Host "[!] $Message" -ForegroundColor $script:Colors.Error
}

function Write-Banner {
    $banner = @"

██████ ██  ██ ▄█████     ▄█████ ▄█████ ▄████▄ ██     █████▄ ██████ ██     
  ██   ██████ ██     ▄▄▄ ▀▀▀▄▄▄ ██     ██▄▄██ ██     ██▄▄█▀ ██▄▄   ██     
  ██   ██  ██ ▀█████     █████▀ ▀█████ ██  ██ ██████ ██     ██▄▄▄▄ ██████ 
                                                                          
  by KL3FT3Z (https://github.com/toxy4ny)
"@
    Write-Host $banner -ForegroundColor Cyan
}


function Invoke-THCRequest {
    param(
        [string]$Endpoint,
        [int]$RetryCount = 3
    )
    
    $url = "$script:BaseUrl/$Endpoint"
    $attempt = 0
    
    while ($attempt -lt $RetryCount) {
        try {
            # Stealth delay
            Start-Sleep -Milliseconds ($Delay * 1000)
            
            $response = Invoke-WebRequest -Uri $url `
                -UserAgent $script:UserAgent `
                -TimeoutSec $Timeout `
                -UseBasicParsing `
                -ErrorAction Stop
            
            if ($response.StatusCode -eq 200) {
                $data = $response.Content -split "`n" | Where-Object { $_ -ne "" }
                return @{
                    Success = $true
                    Data = $data
                    Count = $data.Count
                }
            }
        }
        catch {
            $attempt++
            if ($attempt -ge $RetryCount) {
                return @{
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
            Start-Sleep -Seconds 2
        }
    }
}

function Get-ReverseDNS {
    param([string]$IP)
    
    Write-Info "rDNS request for $IP"
    return Invoke-THCRequest -Endpoint $IP
}

function Get-Subdomains {
    param([string]$Domain)
    
    Write-Info "Search for subdomains for $Domain"
    return Invoke-THCRequest -Endpoint "sb/$Domain"
}

function Get-CNAME {
    param([string]$Domain)
    
    Write-Info "CNAME search for $Domain"
    return Invoke-THCRequest -Endpoint "cn/$Domain"
}

function Get-SubnetRDNS {
    param([string]$Subnet)
    
    Write-Info "rDNS request for subnet $Subnet"
    return Invoke-THCRequest -Endpoint $Subnet
}


function Filter-InterestingHosts {
    param(
        [array]$Data,
        [array]$Keywords
    )
    
    if (-not $Keywords) {
        $Keywords = @('admin', 'dev', 'test', 'staging', 'internal', 'vpn',
                     'backup', 'old', 'legacy', 'api', 'db', 'sql', 'mail')
    }
    
    $interesting = @()
    
    foreach ($line in $Data) {
        foreach ($keyword in $Keywords) {
            if ($line -match $keyword) {
                $interesting += $line
                break
            }
        }
    }
    
    return $interesting
}

function ConvertTo-StructuredData {
    param([array]$RawData)
    
    $structured = @()
    
    foreach ($line in $RawData) {
        $parts = $line -split '\s+', 2
        if ($parts.Count -eq 2) {
            $structured += [PSCustomObject]@{
                IP = $parts[0]
                Hostname = $parts[1]
            }
        }
    }
    
    return $structured
}

function Export-Results {
    param(
        [hashtable]$Results,
        [string]$OutputFile
    )
    
    $extension = [System.IO.Path]::GetExtension($OutputFile).ToLower()
    
    switch ($extension) {
        '.json' {
            $Results | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputFile -Encoding UTF8
            Write-Success "The results are saved: $OutputFile"
        }
        '.csv' {
            $flatData = @()
            foreach ($target in $Results.Keys) {
                $result = $Results[$target]
                if ($result.Success) {
                    foreach ($line in $result.Data) {
                        $parts = $line -split '\s+', 2
                        $flatData += [PSCustomObject]@{
                            Target = $target
                            IP = if ($parts.Count -gt 0) { $parts[0] } else { "" }
                            Hostname = if ($parts.Count -gt 1) { $parts[1] } else { "" }
                        }
                    }
                }
            }
            $flatData | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
            Write-Success "The results are saved: $OutputFile"
        }
        '.xml' {
            $Results | Export-Clixml -Path $OutputFile
            Write-Success "The results are saved: $OutputFile"
        }
        default {
            
            $Results | Out-File -FilePath $OutputFile -Encoding UTF8
            Write-Success "The results are saved: $OutputFile"
        }
    }
}



function Invoke-BulkRecon {
    param(
        [array]$Targets,
        [string]$ReconType
    )
    
    Write-Info "Launching mass intelligence: $($Targets.Count) targets"
    
    $results = @{}
    $jobs = @()
    $completed = 0

    $batches = @()
    for ($i = 0; $i -lt $Targets.Count; $i += $Threads) {
        $end = [Math]::Min($i + $Threads - 1, $Targets.Count - 1)
        $batches += ,@($Targets[$i..$end])
    }
    
    foreach ($batch in $batches) {
        $jobs = @()
        
        foreach ($target in $batch) {
            $job = Start-Job -ScriptBlock {
                param($Target, $Type, $BaseUrl, $UserAgent, $Timeout)
                
                $url = switch ($Type) {
                    'rdns' { "$BaseUrl/$Target" }
                    'subdomain' { "$BaseUrl/sb/$Target" }
                    'cname' { "$BaseUrl/cn/$Target" }
                    'subnet' { "$BaseUrl/$Target" }
                }
                
                try {
                    $response = Invoke-WebRequest -Uri $url `
                        -UserAgent $UserAgent `
                        -TimeoutSec $Timeout `
                        -UseBasicParsing `
                        -ErrorAction Stop
                    
                    $data = $response.Content -split "`n" | Where-Object { $_ -ne "" }
                    
                    return @{
                        Target = $Target
                        Success = $true
                        Data = $data
                    }
                }
                catch {
                    return @{
                        Target = $Target
                        Success = $false
                        Error = $_.Exception.Message
                    }
                }
            } -ArgumentList $target, $ReconType, $script:BaseUrl, $script:UserAgent, $Timeout
            
            $jobs += $job
        }
        
        
        $jobs | Wait-Job | ForEach-Object {
            $result = Receive-Job -Job $_
            $results[$result.Target] = $result
            $completed++
            
            Write-Progress -Activity "Intelligence" `
                -Status "Processed: $completed from $($Targets.Count)" `
                -PercentComplete (($completed / $Targets.Count) * 100)
            
            Remove-Job -Job $_
        }
        
        if ($Stealth) {
            Start-Sleep -Seconds ($Delay * 2)
        }
    }
    
    Write-Progress -Activity "Разведка" -Completed
    
    return $results
}

function Show-Summary {
    param([hashtable]$Results)
    
    Write-Host "`n$('='*60)" -ForegroundColor Cyan
    Write-Host "INTELLIGENCE SUMMARY" -ForegroundColor Cyan
    Write-Host "$('='*60)" -ForegroundColor Cyan
    
    $total = $Results.Count
    $successful = ($Results.Values | Where-Object { $_.Success }).Count
    $failed = $total - $successful
    $totalRecords = ($Results.Values | Where-Object { $_.Success } | Measure-Object -Property Count -Sum).Sum
    
    Write-Host "Total goals: $total"
    Write-Host "Successfully: $successful" -ForegroundColor Green
    Write-Host "Errors: $failed" -ForegroundColor Red
    Write-Host "Total entries: $totalRecords"
    Write-Host "$('='*60)`n" -ForegroundColor Cyan
}

function Show-Results {
    param(
        [hashtable]$Results,
        [int]$Limit = 50
    )
    
    Write-Host "`n[*] Results (first $Limit entries):`n" -ForegroundColor Cyan
    
    $count = 0
    foreach ($target in $Results.Keys) {
        if ($count -ge $Limit) { break }
        
        Write-Host "`n[Target: $target]" -ForegroundColor Yellow
        $result = $Results[$target]
        
        if ($result.Success) {
            foreach ($line in $result.Data) {
                if ($count -ge $Limit) { break }
                Write-Host "  $line"
                $count++
            }
        }
        else {
            Write-Host "  [!] Error: $($result.Error)" -ForegroundColor Red
        }
    }
    
    if ($count -ge $Limit) {
        Write-Host "`n... (rest of the entries are saved to a file)" -ForegroundColor Yellow
    }
}


function Main {
    Write-Banner
       
    if (-not $Target -and -not $InputFile) {
        Write-Error "You must specify -Target or -InputFile"
        Get-Help $MyInvocation.MyCommand.Path
        exit 1
    }
       
    if ($Stealth) {
        $script:Delay = [Math]::Max($Delay, 1.0)
        $script:Threads = [Math]::Min($Threads, 3)
        Write-Warning "Stealth mode: Delay $($script:Delay)s, streams $($script:Threads)"
    }
  
    if ($Target) {
        $result = switch ($Type) {
            'rdns' { Get-ReverseDNS -IP $Target }
            'subdomain' { Get-Subdomains -Domain $Target }
            'cname' { Get-CNAME -Domain $Target }
            'subnet' { Get-SubnetRDNS -Subnet $Target }
        }
        
        $script:Results[$Target] = $result
    }
   
    elseif ($InputFile) {
        if (-not (Test-Path $InputFile)) {
            Write-Error "File not found: $InputFile"
            exit 1
        }
        
        $targets = Get-Content $InputFile | Where-Object { $_ -ne "" }
        Write-Info "Loading Targets: $($targets.Count)"
        
        $script:Results = Invoke-BulkRecon -Targets $targets -ReconType $Type
    }
   
    if ($Keywords) {
        $keywordList = $Keywords -split ',' | ForEach-Object { $_.Trim() }
        Write-Info "Keyword filtering: $($keywordList -join ', ')"
        
        $filteredResults = @{}
        foreach ($target in $script:Results.Keys) {
            $result = $script:Results[$target]
            if ($result.Success) {
                $interesting = Filter-InterestingHosts -Data $result.Data -Keywords $keywordList
                if ($interesting.Count -gt 0) {
                    $filteredResults[$target] = @{
                        Success = $true
                        Data = $interesting
                        Count = $interesting.Count
                    }
                }
            }
        }
        
        if ($filteredResults.Count -gt 0) {
            Write-Success "Interesting hosts found: $(($filteredResults.Values | Measure-Object -Property Count -Sum).Sum)"
            $script:Results = $filteredResults
        }
        else {
            Write-Warning "Nothing was found for the specified keywords."
        }
    }
    
    Show-Summary -Results $script:Results
  
    if ($OutputFile) {
        Export-Results -Results $script:Results -OutputFile $OutputFile
    }
   
    Show-Results -Results $script:Results -Limit 50
    
    Write-Success "`nExploration is complete!"
}


try {
    Main
}
catch {
    Write-Error "Critical error: $($_.Exception.Message)"
    if ($Verbose) {
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
    }
    exit 1
}
finally {
   
    Get-Job | Remove-Job -Force
}