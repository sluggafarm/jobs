# Slugga Farmer v1.0
$wallet = "[Your Wallet Here]"
$local_cache = "C:\temp\_slugga\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"
$my_ids = "4", "5", "6"

$retries = @()
Function Run-SluggaAction {
    param([string]$action, [string]$id)
    $url = "$baseurl/slug/$action/$id/$wallet"
    Write-Host $url
    $need_Retry = $true;
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutVariable $resp
        $need_Retry = $false;
    } catch { 
        Write-Host "Retry $id ... "
    }
    return $need_Retry
}
Function Run-SluggaAction-ForAll {
    param([string]$action)
    foreach($id in $my_ids) {
        $retry = Run-SluggaAction -action $action -id $id
        if ($retry) {
            $retries += $id
        }        
        Sleep -Seconds 3
    }
    Sleep -Seconds 10
    foreach($ret in $retries) {
        $retry = Run-SluggaAction -action $action -id $ret
    }
    $retries = @()
}

# Pick an Action for your sluggaz

# Feed All
# Run-SluggaAction-ForAll -action "feed"
 
# Pet All
# Run-SluggaAction-ForAll -action "pet"

# put all to sleep
# Run-SluggaAction-ForAll -action "sleep"
