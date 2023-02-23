# Depends on data downloaded with the RefreshLocalCache.ps1 recipe.
# This process will consider the local cache of data and determine the correct action for each slugga.
# Slugga MatrixMinder v1.6
$wallet = "[Your Wallet Here]"
$local_cache = "C:\temp\_slugga\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"

$verbose_logging = $false
$sleepLaps = 0

Function Run-SluggaRefreshState {
    param([string]$id)
    $url = "$baseurl/slug/$id/$wallet"
    $outPath = "$($local_cache)$($id).json"
    $need_Retry = $true;    
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -ErrorAction Continue
        $need_Retry = $false;
    } catch { 
        #Write-Host "Refresh Failed!" -f Red
    }
    return $need_Retry
}
Function Run-SluggaAction {
    param([string]$action, [string]$id)
    $url = "$baseurl/slug/$action/$id/$wallet"
    #WRite-Host $url
    $need_Retry = $true;    
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutVariable $resp
        $need_Retry = $false;
    } catch { 
        #Write-Host $_ -f Red
    }
    return $need_Retry
}

do {
    $refresh_tokens = @()
    $failure_tolerance = 100
    [bool]$sleep_action_recommended = $false
    $pst_now = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId( [DateTime]::Now , 'Pacific Standard Time' )

    Write-Host 
    Write-Host $pst_now
    Write-Host
    
    $new_Line_countdown = 6

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
        $sleep_count = 0

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

        if ($verbose_logging) {
            # Check to see if we have to do anything.
            Write-Host $tokenId -f Cyan
            Write-Host "Now (PST): $pst_now" -f Cyan
            Write-Host "active lock: $lock_in_progress_to ($active_lock_wait_time minutes from now)"
            Write-Host "Counts > Pet: $pet_count Feed: $feed_count Sleep: $sleep_count " -f white
            Write-Host "Pet action locked until: $pet_locked_until ($pet_wait_time minutes from now) " -f Magenta
            Write-Host "Feed action locked until: $feed_locked_until ($feed_wait_time minutes from now) " -f Green
            Write-Host "Sleep action locked until: $sleep_locked_until ($sleep_wait_time minutes from now) " -f DarkYellow
        }

        [string]$next_action = "~"
        [int]$wait_time = 9999

        if  ($active_lock_wait_time -gt 0) {
            $next_action = "pause"
            $wait_time = $active_lock_wait_time

        } else {    
            
            if (($pet_count -lt 5 -or $pet_wait_time -lt -360) -and $pet_wait_time -lt 0) {
                $next_action = "pet"
            } else {
                if ($feed_count -lt 3 -and $feed_wait_time -lt 0) {
                    $next_action = "feed"
                } else {
                    if ($feed_count -eq 3 -and $pet_count -eq 5 -and $sleep_wait_time -lt 0 -and $active_lock_wait_time -lt 0) {
                        $next_action = "sleep"
                        $sleep_action_recommended = $true
                    }
                }
            }
        }

        if ($wait_time -ne 9999) {
            Write-Host "[$tokenId.wait.$wait_time.m] " -NoNewline
        } else {
            Write-Host "[$tokenId.$next_action] " -NoNewline
        }        
        
        if ($next_action -ne "pause" -and $next_action -ne "~") {
            [bool]$need_retry = Run-SluggaAction -action $next_action -id $tokenId
            if ($need_retry) {
                $failure_tolerance--
            } 
            $res = Run-SluggaRefreshState -id $tokenId
        }

        if ($failure_tolerance -le 0) { return }

        $new_Line_countdown--
        if ($new_Line_countdown -eq 0) {
            
            Write-Host 

            $new_Line_countdown = 6
        }
    }
    Write-Host 
    Write-Host "Lap complete... pause for 5 minutes..."
    Start-Sleep -Seconds 300
}
while (1 -eq 1)
