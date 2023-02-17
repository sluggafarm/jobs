# Depends on data downloaded with the RefreshLocalCache.ps1 recipe.
# This process will consider the local cache of data and determine the correct action for each slugga.
# Slugga MatrixMinder v1.0
$wallet = "[Your Wallet Here]"
$local_cache = "C:\temp\_slugga\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"
$refresh_tokens = @()
Clear-Host 

Function Run-SluggaRefreshState {
    param([string]$id)
    $url = "$baseurl/slug/$id/$wallet"
    $outPath = "$($local_cache)$($id).json"
    $need_Retry = $true;    
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -ErrorAction Continue
        $need_Retry = $false;
    } catch { 
        Write-Host "Refresh Failed!" -f Red
    }
    return $need_Retry
}
Function Run-SluggaAction {
    param([string]$action, [string]$id)
    $url = "$baseurl/slug/$action/$id/$wallet"
    $need_Retry = $true;    
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutVariable $resp
        $need_Retry = $false;
    } catch { 
        Write-Host "Retry $id ... "
    }
    return $need_Retry
}
$pst_now = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( [DateTime]::Now , 'Pacific Standard Time' ) # Slugga Dates are in PST.
Write-Host 
foreach($file in [System.IO.Directory]::GetFiles($local_cache))
{
    $json = [System.IO.File]::ReadAllText($file)
    $slugdata = ConvertFrom-Json -InputObject $json 
    $tokenId = $slugdata.message.slug.token_id
    $lock_in_progress_to = [System.DateTime]::Parse($slugdata.message.slug.lock_in_progress_to)
    # Write-Host "Processing Slugga $tokenId" -f Yellow
    
    $sleep_locked_until = $pst_now.AddDays(1)
    $feed_locked_until = $pst_now.AddDays(1)
    $pet_locked_until = $pst_now.AddDays(1)
    
    $feed_count = 0
    $pet_count = 0

    foreach($lock in $slugdata.message.slug.locks) {
        if ($lock.action -eq "pet") {
            $pet_count = $lock.count
            $pet_locked_until = [DateTime]::Parse($lock.locked_to)
        }
        if ($lock.action -eq "feed") {
            $feed_count = $lock.count
            $feed_locked_until = [DateTime]::Parse($lock.locked_to)
        }
        if ($lock.action -eq "sleep") {
            $sleep_locked_until = [DateTime]::Parse($lock.locked_to)
        }
    }

    $pet_wait_time = ($pet_locked_until - $pst_now).TotalMinutes
    $feed_wait_time = ($feed_locked_until - $pst_now).TotalMinutes
    $sleep_wait_time = ($sleep_locked_until - $pst_now).TotalMinutes
    $active_lock_wait_time = ($lock_in_progress_to - $pst_now).TotalMinutes

    # Check to see if we have to do anything.
#    WRite-Host "Now (PST): $pst_now" -f Blue
#    WRite-Host "active lock: $lock_in_progress_to ($active_lock_wait_time minutes from now)"
#    Write-Host "Counts > Pet: $pet_count Feed: $feed_count Sleep: $sleep_count " -f Blue
#    Write-Host "Pet action locked until: $pet_locked_until ($pet_wait_time minutes from now) " -f Magenta
#    Write-Host "Feed action locked until: $feed_locked_until ($feed_wait_time minutes from now) " -f Green
#    Write-Host "Sleep action locked until: $sleep_locked_until ($sleep_wait_time minutes from now) " -f DarkYellow

    [string]$next_action = "~" # nothing to do. 

    if  ($active_lock_wait_time -gt 0) {
        $next_action = "pause"
    }
    if ($pet_count -lt 5 -and $pet_wait_time -lt 0 -and $active_lock_wait_time -lt 0) {
        $next_action = "Pet"
    } else {
        if ($feed_count -lt 3 -and $feed_wait_time -lt 0 -and $active_lock_wait_time -lt 0) {
            $next_action = "Feed"
        } else {
            if ($feed_count -eq 3 -and $pet_count -eq 5 -and $sleep_wait_time -lt 0 -and $active_lock_wait_time -lt 0) {
                $next_action = "Sleep"
            }
        }
    }
    Write-Host "$tokenId.$next_action " -NoNewline
    switch($next_action) {
        "Pet" {
            [bool]$need_retry = Run-SluggaAction -action "pet" -id $tokenId
            $refresh_tokens += $tokenId
            break;
        }
        "Feed" {
            [bool]$need_retry = Run-SluggaAction -action "feed" -id $tokenId
            $refresh_tokens += $tokenId
            break;
        }
        "Sleep" {
            [bool]$need_retry = Run-SluggaAction -action "sleep" -id $tokenId
            $refresh_tokens += $tokenId           
            break;
        }       
    }   
}
Write-Host
# Refresh tokens that were updated.
foreach($token in $refresh_tokens) {
    Run-SluggaRefreshState -id $token
}
