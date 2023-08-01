# Prophet Training!
$baseurl = "https://pastelworld.io/slugga-api/api/v1"
$wallet = "# YOUR WALLET HERE #"
$apikey = "# YOUR API KEY FROM SPACEDEX # SEE NOTES #"
$pst_now = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( [DateTime]::Now , 'Pacific Standard Time' )
$local_cache = "C:\temp\_prophet_cache\"

$prophetIds = "1", "2", "3", "4", "5" 
# you have to know your prophet ids, you can only update your own.

Function Run-ServiceCall {
    param([string]$url, [string]$tokenid, [string]$outPath = "")
    $headers = @{ 
        "x-wallet"= $wallet; 
        "x-key"= $apikey;
        "referer"="https://pastelworld.io/spacedex/screen/prophet?pId=$tokenid"
    }
    if ($outPath -ne "") {
        $rr = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -Headers $headers -ErrorAction Continue 
    } else {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $headers -ErrorAction Continue
        return $resp.Content
    }
}

Function Run-ProphetTraining {
    param([string]$prophet_id, [string]$skill)

    WRite-Host $prophet_id $skill -ForegroundColor DarkGreen

    $url = "$baseurl/prophet/actions/$skill/$prophet_id/$wallet"
    Run-ServiceCall -url $url -tokenid $prophet_id
}

Function Run-ProphetRefreshState {
    param([string]$id)
    $url = "$baseurl/prophet/$id/$wallet"
    $outPath = "$($local_cache)$($id).json"
    $need_Retry = $true;    
    try {
        $resp = Run-ServiceCall -url $url -tokenid $id -outPath $outPath
        $need_Retry = $false;
    } catch { 
        #Write-Host "Refresh Failed!" -f Red
    }
    return $need_Retry
}

function Run-ProphetSkillsTraining {
    param([string]$skill, [int]$sleep, [Switch]$noRefresh)
    
    if ($noRefresh.IsPresent) {

    } else {
        foreach($prophetId in $prophetIds) {
            Write-Host "$prophetId " -ForegroundColor DarkCyan -NoNewline
            $res = Run-ProphetRefreshState -id $prophetId
        }
    }
    
    WRite-Host
    WRite-Host $pst_now -f Yellow

    foreach($file in [System.IO.Directory]::GetFiles($local_cache))
    {
        $json = [System.IO.File]::ReadAllText($file)
        $prop = ConvertFrom-Json -InputObject $json 

        $item = $prop.body.prophet
        WRite-Host "$($item.token_id), $($item.bag_trait), $($item.sector), $($item.level), $($item.xp), $($item.lock_in_progress_to)"

        Run-ProphetTraining -prophet_id $item.token_id -skill $skill
    }

    WRite-Host "Waiting.... start at $([DateTime]::Now)"
    Start-Sleep -Seconds $sleep
}

Run-ProphetSkillsTraining -skill "meditate" -sleep 3605
Run-ProphetSkillsTraining -skill "dope-dealer" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "martial-arts" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "fishing-and-sailing" -sleep 7205 -noRefresh
Run-ProphetSkillsTraining -skill "workout" -sleep 3605 -noRefresh
Run-ProphetSkillsTraining -skill "gardening" -sleep 3605 -noRefresh
Run-ProphetSkillsTraining -skill "gaming" -sleep 7205 -noRefresh 
Run-ProphetSkillsTraining -skill "dope-dealer" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "martial-arts" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "meditate" -sleep 3605 -noRefresh
Run-ProphetSkillsTraining -skill "fishing-and-sailing" -sleep 7205 -noRefresh
Run-ProphetSkillsTraining -skill "meditate" -sleep 3605 -noRefresh
Run-ProphetSkillsTraining -skill "dope-dealer" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "arts-and-crafts" -sleep 14405 -noRefresh
Run-ProphetSkillsTraining -skill "mechanic" -sleep 10805 -noRefresh
Run-ProphetSkillsTraining -skill "dope-dealer" -sleep 1805 -noRefresh
Run-ProphetSkillsTraining -skill "dungeon-journey" -sleep 14405 -noRefresh
Run-ProphetSkillsTraining -skill "supernatural-practices" -sleep 7205 -noRefresh
Run-ProphetSkillsTraining -skill "fishing-and-sailing" -sleep 7205 -noRefresh
