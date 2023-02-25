param($sid, $actionname) # COMMAND LINE PARAMETERS!

$wallet = "YOUR WALLET HERE!"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"

Function Run-SluggaAction {
    param([string]$action, [string]$id)

    $url = "$baseurl/slug/$action/$id/$wallet"
    Write-Host $url

    $need_Retry = $true;
    
    try {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -OutVariable $resp
        $need_Retry = $false;
    } catch { 
        Write-Host $_ -f red
    }
    return $need_Retry
}

$res = Run-SluggaAction -id $sid -action $actionname
