# Slugga Farmer v1.0
$wallet = "[Your Wallet Here]"
$local_cache = "C:\temp\_slugga\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"
$my_ids = "4", "5", "6"

Function Run-SluggaRefreshState {
    param([string]$id)
    $url = "$baseurl/slug/$id/$wallet"
    Write-Host $url
    $outPath = "$($local_cache)$($id).json"
    $rr = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -ErrorAction Continue
}
Function Run-SluggaRefreshState-ForAll {   
    foreach($id in $my_ids) {
        Run-SluggaRefreshState -id $id
        Sleep -Seconds 3
    }
}
Run-SluggaRefreshState-ForAll
