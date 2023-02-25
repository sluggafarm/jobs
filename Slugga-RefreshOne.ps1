param($id) # this is a command line parameter

# Slugga Farmer v1.0
$local_cache = "C:\temp\_slugga_cache\"
$wallet = "YOUR WALLET HERE!"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"

Function Run-SluggaRefreshState {
    param([string]$id)

    try {
        $url = "$baseurl/slug/$id/$wallet"
        Write-Host "Updating $id ..." -NoNewLine
        $outPath = "$($local_cache)$($id).json"
        $rr = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -ErrorAction Continue
    } catch { 
        Write-Host "!!!" -f Red -NoNewline
    }
    WRite-Host " " -NoNewLine
}

Run-SluggaRefreshState -id $id
