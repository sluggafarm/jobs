# Slugga State Downloader v1.3
$wallet = "[Your Wallet Here]"
$local_cache = "C:\temp\_slugga\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"
$my_ids = "4", "5", "6"

Function Run-SluggaRefreshState {
    param([string]$id)

    try {
        $url = "$baseurl/slug/$id/$wallet"
        Write-Host $id -NoNewLine
        $outPath = "$($local_cache)$($id).json"
        $rr = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -ErrorAction Continue
    } catch { 
        Write-Host "!!!" -f Red -NoNewline
    }
    WRite-Host " " -NoNewLine
}

Function Run-SluggaRefreshState-ForAll {
    $newline_countdown = 10
    foreach($id in $my_ids) {
        Run-SluggaRefreshState -id $id
        Sleep -Milliseconds 2500
        $newline_countdown--
        if ($newline_countdown -eq 0) {
            $newline_countdown = 10
            Write-Host
        }
    }
}

Run-SluggaRefreshState-ForAll
