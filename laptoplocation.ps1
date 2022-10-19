#####################nulled vars###################
$i=0
$wifiadd = ''
$dtcs='&dtcs='
$ownips=@('109.196.132','178.57.71')
#$ownips=@('109.196.132')
#############ChangeMe##################
$srvproto='http'
$ver2='2.9.5'
$ver='Loader:'+$ver1+' '+'Script:'+$ver2
if ($file -eq $null) {$file='C:\scripts\key.txt'}
if ($file -eq '') {$file='C:\scripts\key.txt'}
$yaapikey = $key
if ($yaapikey -eq '') {$yaapikey= Get-Content $file | Select-String -Pattern 'key='}
if ($yaapikey -eq '') {$yaapikey= Get-Content $file}
if ($yaapikey -eq $null) {$yaapikey= Get-Content $file}
$yaapikey = $yaapikey -replace '$key=',''
$yaapikey = $yaapikey -replace 'key=',''
$yaapikey = $yaapikey -replace ' server=geo.nagaev.biz',''
if ($server -eq '') {$server= Get-Content $file | Select-String -Pattern 'server='}
if ($server -eq '') {$server='geo.whereit.ru'}
if ($server -eq $null) {$server='geo.whereit.ru'}
$server = $server -replace '$server=',''
$server = $server -replace 'server=',''
##################




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


Get-Command '*json'

#Get white IP information
$ipinf =  (Invoke-RestMethod http://ip-api.com/json/)
#$ipinf
$dtcs=$dtcs+' '+$ipinf.query

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

$ip=$ipinf.query
if (($ip -eq '') -or($ip -eq $null)){
    $ipurl = 'http://checkip.amazonaws.com/'
    $ip = Invoke-RestMethod -uri $ipurl
    $dtcs=$dtcs+' empty ip'
}
$dtcs=$dtcs+' '+$ip

#Make json for yandex-locator
#$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$ip+'"}}'
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
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$ip+'"}'+$wifiadd+'}'
write('yaapikey='+$yaapikey)
write('server='+$server)
$Body

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
$charge = [int]$charge
if ($charge -is [int]) {
$charge
} 
else{
    $charge = ''
}
$eastruntime = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedRunTime
$battstatus = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty Status
if ($eastruntime -is [int]) {
$eastruntime
} 
else{
    $eastruntime = ''
}




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
$signal = $signal -replace '%',''
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


$computer = 'localhost'
        $user = $null 
        $lockuser = ''
        $lckuser = $null
#function GetRemoteLogonStatus ($computer = 'localhost') { 
if (Test-Connection $computer -Count 2 -Quiet) { 
    try { 
        $user = gwmi -Class win32_computersystem -ComputerName $computer | select -ExpandProperty username -ErrorAction Stop 
        } 
    catch { $userstatus='Not logged on'; return } 
    try { 
        if ((Get-Process logonui -ComputerName $computer -ErrorAction Stop) -and ($user)) { 
            $userstatus='locked'
            $lockuser = $user
            } 
        } 
    catch { if ($user) { "$user logged on"; $userstatus='logged on' } } 
    } 
#else { "$computer Offline" } 
#}




if (($null -ne ($ownips | ? { $ip -match $_ })) -and ($null -eq ($result.position.latitude | ? { '55.80' -match $_ })) -and ($null -eq ($result.position.longitude | ? { '37.62' -match $_ }))) {
     write-host ('LocalPoint')
#if ($null -ne ($ownips | ? { $ipinf.query -match $_ })) {
    $result.position.latitude = '55.808443'
    $result.position.longitude = '37.629943'
    $result.position.precision = '50'
    $result.position.altitude = '40'
    $ip=$ip+' atol'
    $dtcs=$dtcs+' wrong office location'
}
$rdps='&in1=false'
if (($user -eq $null) -and ($userstatus -eq $null)){
    $rdp=QUERY SESSION
    $rdp = $rdp  -replace "\s+", ","
    $rdp = $rdp  -replace "Active", "Активно"

    $rdp = $rdp -match 'rdp-tcp'
    $rdp = $rdp -match 'Активно'
    $rdp = $rdp | ConvertFrom-Csv -Delimiter ',' -Header 'session','user','id','status'
    $user = $rdp[0].user
    $rdps='&in1=true'+$user
    $userstatus='Logged via RDP'
    }
$dtcs=$dtcs+' '+$user



$winver='&winver=Windows '+[System.Environment]::OSVersion.Version.Major+' '+(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion+' Build '+[System.Environment]::OSVersion.Version.Build
$manuname.PCSystemType
if ($manuname.PCSystemType -eq '') {$PCSystemType = ''}
if ($manuname.PCSystemType -eq '6') {$PCSystemType = '&type='+'Appliance PC'}
if ($manuname.PCSystemType -eq '1') {$PCSystemType = '&type='+'Desktop'}
if ($manuname.PCSystemType -eq '4') {$PCSystemType = '&type='+'Enterprise Server'}
if ($manuname.PCSystemType -eq '8') {$PCSystemType = '&type='+'other'}
if ($manuname.PCSystemType -eq '2') {$PCSystemType = '&type='+'Mobile device'}
if ($manuname.PCSystemType -eq '7') {$PCSystemType = '&type='+'Performance server'}
if ($manuname.PCSystemType -eq '5') {$PCSystemType = '&type='+'SOHO Server'}
if ($manuname.PCSystemType -eq '0') {$PCSystemType = '&type='+'unspecified'}
if ($manuname.PCSystemType -eq '3') {$PCSystemType = '&type='+'Workstation'}
$memory=[math]::Round([long]$manuname.TotalPhysicalMemory/([math]::Pow(1024,3)),0)
$memory
$serial = Get-wmiobject win32_bios | ForEach-Object {$_.serialnumber}
$serial
#http-get to geoserver
if ($manuname.Manufacturer -ne '') {$Manufacturer = '&Manufacturer='+$manuname.Manufacturer}
if ($manuname.SystemFamily -ne '') {$SystemFamily = '&versionHw='+$manuname.SystemFamily}
if ($manuname.Model -ne '') {$Model = '&Model='+$manuname.Model}
if ($manuname.NumberOfLogicalProcessors -ne '') {$NumberOfLogicalProcessors = '&NumberOfLogicalProcessors='+$manuname.NumberOfLogicalProcessors}
if ($manuname.NumberOfProcessors -ne '') {$NumberOfProcessors = '&NumberOfProcessors='+$NumberOfProcessors.Model}
if ($serial -ne '') {$serial = '&serial='+$serial}
if ($memory -ne '') {$memory = '&memory='+$memory}
if ($eastruntime -ne '') {$eastruntime = '&eastruntime='+$eastruntime}
if ($battstatus -ne '') {$battstatus = '&battstatus='+$battstatus}

$result.position.altitude = '&altitude='+$result.position.altitude
if ($ipinf.zip -ne '') {$ipinf.zip = '&zip='+$ipinf.zip}
if ($ipinf.isp -ne '') {$ipinf.isp = '&operator='+$ipinf.isp}
if ($user -ne '') {$login = '&driverUniqueId='+$user}
if ($username.Item(7) -ne '') {$logt = '&logintime='+$username.Item(6)+' '+$username.Item(7)}
if ($domain.domain -ne '') {$domain = '&domain='+$domain.domain}
if ($ssid -ne '') {$ssid = '&ssid='+$ssid}
if ($signal -ne '') {$signal = '&rssi='+$signal}
if ($network.InterfaceAlias -ne $null) {$networkInterfaceAlias = '&InterfaceAlias='+$network.InterfaceAlias}
if ($network.Name -ne $null) {$networkName = '&net_name='+$network.Name}
if ($userstatus -ne '') {$userstat = '&status='+$userstatus}
#if ($userstatus.СЕАНС -match '^\d+$') {$userstat = '&UserStatus='+$userstatus.ID}
if ($lockuser -ne '') {$lckuser = '&Locked by='+$lockuser}
if ($charge -ne '') {$charge = '&batt='+$charge}
$Ignition = ''
if ($userstatus -eq 'logged on') {$Ignition = '&ignition=true'}
if ($userstatus -eq 'locked') {$Ignition = '&ignition=false'}
if ($userstatus -eq 'Logged via RDP') {$Ignition = '&ignition=true'}

$localip = Get-NetIPAddress -InterfaceAlias $network.InterfaceAlias
$localip | ConvertTo-Json
if ($localip.IPAddress -ne '') {$localip = '&localIP='+$localip.IPAddress}


#networkinterfacealias
#localip

$uri= $srvproto+'://'+$server+'/?id='+$deviceid+'&timestamp='+$ts+'&lat='+$result.position.latitude+'&lon='+$result.position.longitude+$result.position.altitude+'&realip='+$ip+$charge+$ipinf.isp+'&power='+$ac+'&accuracy='+$result.position.precision+'&vin='+$deviceid+$ipinf.zip+$login+$domain+$logt+$ssid+$signal+$networkName+$userstat+$lckuser+$networkInterfaceAlias+'&versionFw='+$ver+$localip+'&channel=local_script'+$PCSystemType+$serial+$Manufacturer+$SystemFamily+$Model+$NumberOfLogicalProcessors+$serial+$memory+$eastruntime+$battstatus+$winver+$dtcs+$Ignition+$rdps
$debug= QUERY SESSION
try{
Invoke-RestMethod -Uri $uri -Method 'Post' -Body $debug -ContentType 'application/x-www-form-urlencoded' -Verbose
}

                    catch  {
                    Write('HTTP Error')
                    $tlogin=$user
                    $user
                    $tlogin = $tlogin -replace 'ATOL\\',''
                    $tlogin = $tlogin -replace 'NAGAEV\\',''
                    $tlogin

                    $body = '{"name": "'+$tlogin+'@atol.ru","uniqueId": "'+$deviceid+'","disabled": false,"positionId": 0,"groupId": 2,"attributes": {}}'
                    Invoke-RestMethod  -Headers @{Authorization=("Basic {0}" -f $base64)} -Uri $apiUri  -Method 'Post' -Body $body -ContentType 'application/json' -Verbose
                       #Start-Sleep 30
                       #Invoke-RestMethod -Uri $uri  -Method 'Post' -Body $debug -ContentType 'application/x-www-form-urlencoded' -Verbose
              
                    }





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
$yaapikey
$server
Write-Host('-----------------DEBUG-----------------')
$debug
$rdps
$user
$userstatus
$userstat
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
