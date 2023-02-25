# Slugga Brute Force Farming 1.0
$wallet = "YOUR WALLET HERE"
$local_cache = "C:\temp\_slugga_cache\"
$baseurl = "https://pastelworld.io/slugga-api/api/v1"

Function Get-Sluggas {
    $output = @()
    foreach($file in [System.IO.Directory]::GetFiles($local_cache))
    {
        $json = [System.IO.File]::ReadAllText($file)
        $slugdata = ConvertFrom-Json -InputObject $json 
        $output += $slugdata
    }
    return $output
}

Function Execute-FarmAllAction {
    param($actionName, $actionCount)
    Write-Host "$actionName #$actionCount"
    foreach($s in $sluggas) {
        .\Farm-Action.ps1 -sid $s.message.slug.token_id -actionname $actionName
        Start-Sleep -Milliseconds 500
        .\Slugga-RefreshOne.ps1 -id $s.message.slug.token_id
    }
}

$sluggas = Get-Sluggas

Write-Host "Headcount: " $sluggas.count

$gap1 = (15 * 60) + 2
$gap2 = (60 * 60) + 2
$gap3 = (75 * 60) + 2
$gap4 = (30 * 60) + 2
$gap5 = (105  * 60) + 2

Execute-FarmAllAction -actionName "pet" -actionCount "1" # 3:00AM
Start-sleep -Seconds $gap1
Execute-FarmAllAction -actionName "feed" -actionCount "1" # 3:15AM
Start-sleep -Seconds $gap2
Execute-FarmAllAction -actionName "pet" -actionCount "2" # 4:15AM
Start-sleep -Seconds $gap3
Execute-FarmAllAction -actionName "pet" -actionCount "3" # 5:30AM
Start-sleep -Seconds $gap3
Execute-FarmAllAction -actionName "feed" -actionCount "2" # 6:45AM
Start-sleep -Seconds $gap4
Execute-FarmAllAction -actionName "pet" -actionCount "4" # 7:15AM
Start-sleep -Seconds $gap3
Execute-FarmAllAction -actionName "pet" -actionCount "5" # 8:30AM
Start-sleep -Seconds $gap5
Execute-FarmAllAction -actionName "feed" -actionCount "3" # 10:15AM
Start-sleep -Seconds $gap4
Execute-FarmAllAction -actionName "sleep" -actionCount "1" # 10:45AM



