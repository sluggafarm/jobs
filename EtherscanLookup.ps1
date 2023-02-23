$EtherscanAPIKey = "[Your Etherscan API Key]"
$wallet = "[Your wallet]"

$slug_contract_addr = "0xb5483d93ee8757055298cdfe7596b36719398487" # no need to change these
$etherscan_api_url = "https://api.etherscan.io/api?module=account&action=tokennfttx&contractaddress=$slug_contract_addr&address=$wallet&sort=asc&apikey=$EtherscanAPIKey"

$response = Invoke-WebRequest -UseBasicParsing -Uri $etherscan_api_url
$json = $response.Content
$results = ConvertFrom-Json -InputObject $json
$newLineCountdown = 10
foreach($result in $results.result) {
    WRite-Host "$($result.tokenID), " -NoNewline
    $newLineCountdown--;
    if ($newLineCountdown -eq 0) {
        WRite-Host
        $newLineCountdown = 10
    }
}
