cls
Get-Command '*json'
$yaapikey = 'yandex_locator_token'
$server='geo.whereit.ru'
$srvproto='https'
$users = @('users_for_track')
$i = 0

ForEach ($item in $users){
    $users[$i]='"CID":"'+$users[$i]
    $last = Select-String $users[$i] 'adguard_dir\data\querylog.json' | Select-Object -Last 1
    $last | ConvertTo-JSON
    
    if ($last -ne $null){
        $line = $last.line
        $line = $line | ConvertFrom-JSON


        $date1 = Get-Date -Date "01/01/1970"
        $date2 = $line.T
        $ts=[int](New-TimeSpan -Start $date1 -End $date2).TotalSeconds
        $ts= $ts-3600*3

        $Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$line.IP+'"}}'

        #Yandex-locator http-post
        $Uri = "https://api.lbs.yandex.net/geolocation/"
        $result = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body
        $result | ConvertTo-Json
        $result.position.latitude = $result.position.latitude -replace ',','.'
        $result.position.longitude = $result.position.longitude -replace ',','.'
        $Body
        $result
        if ($result.position.precision -gt 4000) {$result.position.precision=0}
        $geourl = 'http://ip-api.com/json/'+$line.IP
        $geourl
        $geo =  (Invoke-RestMethod -Uri $geourl)

        $uri= $srvproto+'://'+$server+'/?id='+'adg_'+$line.CID+'&timestamp='+$ts+'&lat='+$result.position.latitude+'&lon='+$result.position.longitude+'&realip='+$line.IP+'&accuracy='+$result.position.precision+'&zip='+$geo.zipcode+'&isp='+$geo.isp
        Invoke-WebRequest -Uri $uri
        $uri
        }
    $i=$i+1
}



# SIG # Begin signature block
# MIIIDgYJKoZIhvcNAQcCoIIH/zCCB/sCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+3qHQF9oHLYFhCIKxCBoV+3b
# h7ygggV6MIIFdjCCBF6gAwIBAgITWwAAADNcpHyNQRXbdwADAAAAMzANBgkqhkiG
# 9w0BAQsFADBGMRMwEQYKCZImiZPyLGQBGRYDYml6MRYwFAYKCZImiZPyLGQBGRYG
# bmFnYWV2MRcwFQYDVQQDEw5uYWdhZXYtSE1BRC1DQTAeFw0yMjA3MjAxNjMwMjJa
# Fw0yMzA3MjAxNjMwMjJaMFcxEzARBgoJkiaJk/IsZAEZFgNiaXoxFjAUBgoJkiaJ
# k/IsZAEZFgZuYWdhZXYxDTALBgNVBAsTBEhvbWUxGTAXBgNVBAMTEEFsZWtzYW5k
# ciBOYWdhZXYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPmaNODld9
# 9JeJGtR0eLjhrEP8N33JITGXdm4the88WBGhgczsHj/yTCAxjGSJIhkOOimg2hfP
# 4bnoGIFMub3YmTUbKiT4drSzcZQtb9B1TjdG4ikr2GNfDOnY6EVbGoBA6Bz+qRxP
# 5VKQyBXfRiejxPcPrhX4GpvRSgxbQsvM50RhrkLubS0ngaIGySjs32BEbN6NBnXt
# RqZlEeIB9+vdzXpyTQ4q5p1f8YRABC3+iNuRdADSYvFjTbVlW6Fso9ZmRS927Jlz
# nKjHS2tAZ3g3ufj6rPycafuBqQAW8KEKU3ndpaMhrPU2QgqtyRHZ+k82oIoiCMP2
# 0u8z62rzMkr5AgMBAAGjggJKMIICRjAlBgkrBgEEAYI3FAIEGB4WAEMAbwBkAGUA
# UwBpAGcAbgBpAG4AZzATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMC
# B4AwHQYDVR0OBBYEFEZUbY+2eyqmGbQYzL1sofFzX66UMB8GA1UdIwQYMBaAFAtL
# 8FDIAoH67o3comq3yuhKORzqMIHLBgNVHR8EgcMwgcAwgb2ggbqggbeGgbRsZGFw
# Oi8vL0NOPW5hZ2Fldi1ITUFELUNBKDMpLENOPWhtYWQsQ049Q0RQLENOPVB1Ymxp
# YyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24s
# REM9bmFnYWV2LERDPWJpej9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/
# b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgb8GCCsGAQUFBwEBBIGy
# MIGvMIGsBggrBgEFBQcwAoaBn2xkYXA6Ly8vQ049bmFnYWV2LUhNQUQtQ0EsQ049
# QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
# bmZpZ3VyYXRpb24sREM9bmFnYWV2LERDPWJpej9jQUNlcnRpZmljYXRlP2Jhc2U/
# b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTAoBgNVHREEITAfoB0G
# CisGAQQBgjcUAgOgDwwNYXBAbmFnYWV2LmJpejANBgkqhkiG9w0BAQsFAAOCAQEA
# JFSrkFjOy7q85BEMALT9BwXYPgn9n3JvLplLBmKsfmhxDdCxtZ5Cc+0f15zTQqxK
# nefGfuwkjnDmJEsjRRNDSwub2xRFEWM0fAfgafTioofhMXMTLQua5bkmAGqta8Z4
# cL0BQuaj3MkGiU2PGmcOV2susis54RYdAfEpNJ5EfQhqly1g16rtBQnwZ6g8yDZu
# GciTMHDhPEpo+C5p5uKFa3b2YCAd+BcF9zJ61ua2ZL0SatvUNX7c7LnHJ5vE5VCI
# K2lM2+OsqE2G2UGGxGT6OP+z1j+sx1XV+IFkETvH73McDxgQR9rl1ez7mjJGAfQ3
# 05nhj3+mOaqaZo3HLqV8yjGCAf4wggH6AgEBMF0wRjETMBEGCgmSJomT8ixkARkW
# A2JpejEWMBQGCgmSJomT8ixkARkWBm5hZ2FldjEXMBUGA1UEAxMObmFnYWV2LUhN
# QUQtQ0ECE1sAAAAzXKR8jUEV23cAAwAAADMwCQYFKw4DAhoFAKB4MBgGCisGAQQB
# gjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYK
# KwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFAkFD73r
# tGSgyLdHsyOvmUrPL/lYMA0GCSqGSIb3DQEBAQUABIIBAJRmQxn8qevlMz7pJ+1f
# udsgnleJKbSZpfVWX+qI6E4Z1G6FqZqEm/5k1sq3Zp+zRJ36FU08cSoTtumGp5Fz
# Gom5JW74MpEWulsFkYguFjAwIMqgrPkqZ+TMumUlZsc/cn1hmduwiz5JWD/d527K
# wt53Saj7MaCQJW658wTzkqhAw0f25g7nl4O4MRgQ0J4dhYpTCiOsYeF/prwV95ze
# IS0aOOJfeuv1kqpqhqtHKzbA89PmaFEPlineGFaKS1KmaRsYCBXoeinWpx27QNdT
# uIb6AECWBhoKyG9q9Xv7MBaFZLd25W1fCDSqfgBcMV9fcPjXw/uBLMuy/c2Cj7Nx
# euc=
# SIG # End signature block
