cls
$rtime= Get-Random -Maximum 600
$rtime
Start-Sleep -Seconds $rtime
#######change for your trackmiddle server
$server=$server
#####################nulled vars###################
$i=0
$wifiadd = ''
$dtcs=''
$user = $null
$userstatus = $null
$rdps = $null
$satVisible=''
$networkInterfaceAlias=''
$net_name=''
$SystemFamily=''
#############ChangeMe##################
$srvproto='https'
$ver2='3.2.1 via git'
$ver='Script:'+$ver2
##################
Get-Command '*json'

$compsystem=Get-WmiObject Win32_ComputerSystem
$deviceid=$compsystem.name+"."+$compsystem.domain
$deviceid=$deviceid.ToLower()
#$domain=$compsystem.domain

#Console User Loggined
$username = query user /server:localhost
$username = $username -match 'console'
if ($username -ne $null) {
    $username = $username -replace '\s+','!'
    $username = $username -split '!'
    #$username = $username.Item(1)+'@'+$domain.domain+'-'+$username.Item(6)+'-'+$username.Item(7)
    }
else{$username='system'}


#Get white IP information
$ipinf =  (Invoke-RestMethod http://ip-api.com/json/)
if ($dtcs -ne '') {$dtcs='&dtcs='+$ipinf.query}

$latitude =$ipinf.lat
$longitude=$ipinf.lon

#Get avialable WiFi networks
$wlan = netsh wlan show network mode=bssid

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
}


#Make json for yandex-locator
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
$Body = 'json={"common": {"version": "1.0", "api_key": "yaapikey"}, "ip": {"address_v4": "'+$ip+'"}'+$wifiadd+'}'

#Calculate unix seconds timestamp
$ts=[int][double]::Parse((Get-Date (get-date).touniversaltime() -UFormat %s))

#Check charge and power, processing for pc
$charge = Get-CimInstance -ClassName Win32_Battery | Select-Object -ExpandProperty EstimatedChargeRemaining
$ac = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine
if ($charge -eq $null) {$charge = 100} 
#if (($ac -eq $null) -or ($ac -eq 'True')) {$ac = 'AC'} else {$ac = 'Battery'}
if (($ac -eq $null) -or ($ac -eq 'True')) {$ac = 'true'} else {$ac = 'false'}
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




#[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
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
#$manuname.Manufacturer
$manuname.SystemFamily
#$manuname.Model


$network = Get-NetConnectionProfile
$network | ConvertTo-Json
$network.InterfaceAlias
$network.Name


$computer = 'localhost'
        $user = $null 
        $lockuser = ''
        $lckuser = $null
        $userstatus = $null
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





if (($user -eq $null) -and ($userstatus -eq $null)){
    $rdp = QUERY SESSION
    $rdp = $rdp  -replace "\s+", ";"
    $rdp = $rdp  -replace "Active", "Активно"
    $rdp = $rdp -match 'rdp-tcp#'
    $rdp = $rdp -match 'Активно'
    $rdp = $rdp | ConvertFrom-Csv -Delimiter ';' -Header 'session','user','id','status'
    $user
    
    if (($rdp[0].user -ne '') -and ($rdp[0].user -ne $null)){
        $user = $rdp[0].user
        if ($user -match 'rdp-tcp'){$user = $rdp[0].id}
        $userstatus = "logged rdp"
    }
}
$user=$user.ToLower()
$domain=$compsystem.domain.Remove($compsystem.domain.IndexOf('.'))
if ($user -notmatch $domain){$user = $domain+'\'+$user}

if ($userstatus -eq $null){$userstatus='dont login'}


#$winver='&winver=Windows '+[System.Environment]::OSVersion.Version.Major+' '+(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion+' Build '+[System.Environment]::OSVersion.Version.Build
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
#$memory=[math]::Round([long]$manuname.TotalPhysicalMemory/([math]::Pow(1024,3)),0)
#http-get to geoserver
#if ($manuname.Manufacturer -ne '') {$Manufacturer = '&Manufacturer='+$manuname.Manufacturer}
if ($manuname.SystemFamily -ne $null) {$SystemFamily = '&versionHw='+$manuname.SystemFamily}
#if ($manuname.Model -ne '') {$Model = '&Model='+$manuname.Model}
#if ($manuname.NumberOfLogicalProcessors -ne '') {$NumberOfLogicalProcessors = '&NumberOfLogicalProcessors='+$manuname.NumberOfLogicalProcessors}
#if ($manuname.NumberOfProcessors -ne '') {$NumberOfProcessors = '&NumberOfProcessors='+$NumberOfProcessors.Model}
#if ($memory -ne '') {$memory = '&memory='+$memory}
if ($eastruntime -ne '') {$eastruntime = '&eastruntime='+$eastruntime}
if ($battstatus -ne $null) {$battstatus = '&battstatus='+$battstatus}

if ($ipinf.zip -ne '') {$ipinf.zip = '&zip='+$ipinf.zip}
if ($ipinf.isp -ne '') {$ipinf.isp = '&operator='+$ipinf.isp}
if ($user -ne '') {$login = '&userId='+$user}
if ($username.Item(7) -ne '') {$logt = '&logintime='+$username.Item(6)+' '+$username.Item(7)}
if ($compsystem.domain -ne '') {$domain = '&domain='+$compsystem.domain}
if ($ssid -ne '') {$ssid = '&ssid='+$ssid}
if ($signal -ne '') {$signal = '&rssi='+$signal}
if ($network.InterfaceAlias -ne $null) {$networkInterfaceAlias = '&InterfaceAlias='+$network.InterfaceAlias}
if ($network.Name -ne $null) {$networkName = '&net_name='+$network.Name}
if ($userstatus -ne '') {$userstat = '&status='+$userstatus}
#if ($userstatus.СЕАНС -match '^\d+$') {$userstat = '&UserStatus='+$userstatus.ID}
if ($lockuser -ne '') {$lckuser = '&Locked by='+$lockuser}
if ($charge -ne '') {$charge = '&batt='+$charge}
if ($manuname.PCSystemType -ne '2'){
    $charge=''
    $ac = 'AC'
}
$Ignition = '&ignition=false'
if ($userstatus -eq 'logged on') {$Ignition = '&ignition=true'}
if ($userstatus -eq 'locked') {$Ignition = '&ignition=false'}
if ($userstatus -eq 'logged rdp') {$Ignition = '&ignition=true'}
if ($userstatus -eq 'dont login') {$Ignition = '&ignition=false'}

$satVisible='&satVisible='+$warr.Count



$localip = Get-NetIPAddress -InterfaceAlias $network.InterfaceAlias
$localip | ConvertTo-Json
if ($localip.IPAddress -ne '') {$localip = '&localIP='+$localip.IPAddress}


$uri= $srvproto+'://'+$server+'/?id='+$deviceid+'&timestamp='+$ts+'&lat='+$latitude+'&lon='+$longitude+$login+'&realip='+$ip+$charge+$ipinf.isp+'&power='+$ac+'&vin='+$deviceid+$ipinf.zip+$domain+$logt+$ssid+$signal+$networkName+$userstat+$lckuser+$networkInterfaceAlias+'&versionFw='+$ver+$localip+'&channel=local_script'+$PCSystemType+$SystemFamily+$eastruntime+$battstatus+$dtcs+$Ignition+$satVisible


Invoke-RestMethod -Uri $uri -Method 'Post' -Body $body -ContentType 'application/x-www-form-urlencoded' -Verbose

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
