#############ChangeMe##################
$server='geo.whereit.ru'
$srvproto='https'
$yaapikey= Get-Content C:\scripts\key.txt
##################

$i=0
$wifiadd = ''

$deviceid=[System.Net.Dns]::GetHostByName($env:computerName).HostName


#Console User Loggined
$username = query user /server:localhost
$domain = Get-WmiObject Win32_ComputerSystem
#$username
$username = $username -match 'console'
if ($username -ne $null) {
    $username = $username -replace '\s+','!'
    $username = $username -split '!'
    #$username = $username.Item(1)+'@'+$domain.domain+'-'+$username.Item(6)+'-'+$username.Item(7)
    }
else{$username='system'}


cls
Get-Command '*json'

#Get white IP information
$ipinf =  (Invoke-RestMethod http://ip-api.com/json/)
$ipinf


#Get avialable WiFi networks
$wlan = netsh wlan show network mode=bssid
#$wlan

#Clear BSSIDs
$warr = $wlan -match 'BSSID'
$warr = $warr -replace ':',''
$warr = $warr -replace '^.*(?=.{12}$)'

#Clear signal
$wsarr = $wlan -match '%'
$wsarr = $wsarr -replace '%',''
$wsarr = $wsarr -replace '^.*(?=.{2}$)'


#Make json for yandex-locator
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$ipinf.query+'"}}'
if ($warr.Item(0) -ne $null){
    $wifiadd = ', "wifi_networks": [ '
    ForEach ($item in $warr){
        $warr.Item($i)
        $wifiadd = $wifiadd + '{"mac": "'+$warr.Item($i)+'", "signal_strength": "'+$wsarr.Item($i)+'", "age": 500},'
        $i= $i+1
        }
    $wifiadd = $wifiadd -replace ".{1}$"
    $wifiadd = $wifiadd + ']'
    }
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$ipinf.query+'"}'+$wifiadd+'}'
#$Body

#Yandex-locator http-post
$Uri = "https://api.lbs.yandex.net/geolocation/"
#$Body
$result = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body
$result | ConvertTo-Json
$result.position.latitude = $result.position.latitude -replace ',','.'
$result.position.longitude = $result.position.longitude -replace ',','.'

#Disable accuraty if precision to hight
if ($result.position.precision -gt 4000) {$result.position.precision=0}

#Calculate unix seconds timestamp
$date1 = Get-Date -Date "01/01/1970"
$date2 = [System.DateTime]::UtcNow
$ts=[int](New-TimeSpan -Start $date1 -End $date2).TotalSeconds

#Check charge and power, processing for pc
$charge = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
$ac = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine
if ($charge -eq $null) {$charge = 100} 
if (($ac -eq $null) -or ($ac -eq 'True')) {$ac = 'AC'} else {$ac = 'Battery'}



[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
$networkInterfaceAlias=''
$net_name=''
$netsh = netsh wlan sh int | Select-String signal,ssid,сигнал
$netsh

$ssid = $netsh.Item(0)
$ssid = $ssid -replace 'SSID',''
$ssid = $ssid -replace ':',''
$ssid = $ssid -replace '\s',''

$signal = $netsh.Item(2)
$signal = $signal -replace 'Сигнал',''
$signal = $signal -replace ':',''
$signal = $signal -replace '\s',''

$ssid
$signal

$manuname = Get-CimInstance -ClassName Win32_ComputerSystem
$manuname | ConvertTo-Json
$manuname.Manufacturer
$manuname.SystemFamily
$manuname.Model


$network = Get-NetConnectionProfile
$network | ConvertTo-Json
$network.InterfaceAlias
$network.Name





#http-get to geoserver
if ($ipinf.zip -ne '') {$ipinf.zip = '&zip='+$ipinf.zip}
if ($ipinf.isp -ne '') {$ipinf.isp = '&isp='+$ipinf.isp}
if ($username.Item(1) -ne '') {$login = '&login='+$username.Item(1)}
if ($username.Item(7) -ne '') {$logt = '&logintime='+$username.Item(6)+' '+$username.Item(7)}
if ($domain.domain -ne '') {$domain = '&domain='+$domain.domain}
if ($ssid -ne '') {$ssid = '&ssid='+$ssid}
if ($signal -ne '') {$signal = '&signal='+$signal}
if ($network.InterfaceAlias -ne $null) {$networkInterfaceAlias = '&InterfaceAlias='+$network.InterfaceAlias}
if ($network.Name -ne $null) {$networkName = '&net_name='+$network.Name}



$localip = Get-NetIPAddress -InterfaceAlias $network.InterfaceAlias
$localip | ConvertTo-Json
if ($localip.IPAddress -ne '') {$localip = '&localIP='+$localip.IPAddress}



$uri= $srvproto+'://'+$server+'/?id='+$deviceid+'&timestamp='+$ts+'&lat='+$result.position.latitude+'&lon='+$result.position.longitude+
'&realip='+$ipinf.query+'&batt='+$charge+$ipinf.isp+'&power='+$ac+'&accuracy='+$result.position.precision+'&computer_name='+$deviceid+$ipinf.zip+
$login+$domain+$logt+$ssid+$signal+$networkInterfaceAlias+$networkName+$localip
Invoke-RestMethod -Uri $uri -OutFile 'loc.log' -TimeoutSec 2
del 'loc.log'


#Write vars
write('localIP='+$localip.IPAddress)
write('DeviceID='+$deviceid)
write('Username='+$username)
write('timestamp='+$ts)
write('latitude='+$result.position.latitude)
write('longitude='+$result.position.longitude)
write('Charge='+$charge)
write('Power='+$ac)
write('URL='+$uri)
write('ZIP='+$ipinf.zip)
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
