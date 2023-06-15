# Get Leaderboard
$apikey = "[Your API Key, borrow from Dev Tools in Browser SpaceDex]"
$wallet = "[Your Wallet Here]"

Function Run-ServiceCall {
    param([string]$url, [string]$tokenid, [string]$outPath = "")
    # The team has added some security to the API.  Let's see if we can hack it! 
    $headers = @{ 
        "x-wallet"= $wallet; 
        "x-key"= $apikey;
        "referer"="https://pastelworld.io/spacedex/screen/slugga?sId=$tokenid"
    }
    if ($outPath -ne "") {
        $rr = Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $outPath -Headers $headers -ErrorAction Continue 
    } else {
        $resp = Invoke-WebRequest -UseBasicParsing -Uri $url -Headers $headers -ErrorAction Continue
        return $resp.Content
    }
}
$globalCount = 1
Function Get-Leaderboard {
    param([int]$page=1)
    $lb_url = "https://pastelworld.io/slugga-api/api/v1/wallet/leader-board?page=$page"
    $res = Run-ServiceCall -url $lb_url
    $obj = ConvertFrom-Json -InputObject $res    
    $dt = [System.DateTime]::Now.ToString("yyyy-MM-dd-HH")
    $filename = "C:\apps\bc\pastelworld\stats\shard-leaders-$dt.txt"
    $lines = @()
    $prev = -1
    for($q = 0; $q -lt $obj.body.data.length; $q++ ) {
        $leader = $obj.body.data[$q]
	    $line = "$($leader.address) $($leader.shard)"
        $lines += $line
  	    $value = [Convert]::ToInt32($leader.shard)
	    $delta = 0
        if ($prev -ne -1) {
		    $delta = $value - $prev
        }
        Write-Host $globalCount $leader.address $value $delta -f Green
        $prev = $value
        $globalCount++
    }
    $lines += ""
    $lines += $dt
    [System.IO.File]::WriteAllLines($filename, $lines)
}
Get-Leaderboard -page 1
#Get-Leaderboard -page 2
#Get-Leaderboard -page 3
#Get-Leaderboard -page 4
