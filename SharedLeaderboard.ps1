$baseurl = "https://pastelworld.io/slugga-api/api/v1/shards/"
$top_wallets = "0xDDE733b93C63a777b9ff1De617BBF54dB16410D0", "0xD2B4B1029733005b0bFC81ad1b944816C07fe5F5", 
            "0x8011C924C461efC9931D00a3f36EbF663c5d98FC", "0xc9E48BF45feFEAd335C8679Afe7c5F22e6060997", "0x39958D4FEB1f24921BD9d52f7A9Eca98BbB10C3d",
            "0x97C3157A9874c5B3d64c5B7DD45Ad55ee85d1130", "0x32f70C85E5F0f991B839304C9d48A8178CB89e91", "0xB32B29A1003200259aDb96932eE613e487901Ada", "0x06ef95236a4Fe41Ec49648af4c177115031bF149", 
            "0x024b7EF836230f08998B9b667d405b685D2A9700", "0xDf2498842e57c49BF77ebe9f8Dc65D9f4A24efF1", "0xe2b28eeaE32E217F8618324E4C2F456DF307EDFF", "0xa5839867519C6f56b20EAF86E66e7c1aA99A152C", 
            "0x02588dd8A4C15e316A024055f314Cb41e992D766", "0xE172EBFB4b9Bb7980b19745E2253Bb1b984c4aD0", "0xBB8fe2022eC7a890D7290C9F70e0Abcd7a07C6Eb", "0x19B2Fe4A5342808404dAFdD0c9029B7eEBDB5B92", 
            "0xc2b2568982707E9691DCE7BB23501071BC06f415", "0x2356F17217aA8Ec4A43Ca33489B963BF47483478", "0x8B459B9F8cc957055A2a68A2f78eB44d049e796a", "0x8c4d0Cd10862211Ef2b273845825B7335950233D", 
            "0x4f77DDcEc2e6ce9E2fb26d5bb45dBa804AB2CEC1", "0xBeb4ac8e642b7bF5F107989A98eA7F671560eD49", "0xF07feb3a5D26906F8f62e0eE9EA03e4529587992", "0x2786436A118E5bc0CB8ee3D7b34FE9f33d55B1cA", 
            "0xC89F63983E61ed1560B54e7cDd57Dea13beEC47F", "0x95817A76D90623f8a9C5DfB3005f1A7147972966", "0xc656B84f3E4A8fdCb3CE70FA97bAdABAE83C2691", "0x34Cc0455Fa50fD3EA398934b66BD178a7d497c9C"           
            
Function Run-ServiceCall {
    param([string]$url)
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $url
    return $resp.Content
}
Function Get-Shards {
    param([string]$wallet)
    $wallet_url = "$baseurl$wallet"
    $res = Run-ServiceCall -url $wallet_url
    $res_obj = ConvertFrom-Json -InputObject $res
    return $res_obj.body.shard
}
Function Run-ShardLeaderboard {
    foreach($w in $top_wallets) {
        $res = Get-Shards -wallet $w
        WRite-Host $w, $res
    }
}
Run-ShardLeaderboard
