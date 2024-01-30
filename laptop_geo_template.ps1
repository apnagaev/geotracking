##must change
$yaapikey=@('') #comma separated tokens for yandex locator
$ipgeokey=@('') #comma separated tokens for ipgeolocation.io
$server="" #osmand port
$srvproto='https' #http\https
$apiUri="" #traccar api endpoint
$base64="" #traccar token for add unknown devices
$ver='5.5.3'

#####################nulled vars###################
$i=0
$wifiadd = ''
$dtcs='&dtcs='
$user = $null
$userstatus = $null
$rdps = $null
$ownips=@('') #comma separated ownips
$satVisible=''
#default position for ownips
$tresult = @{
  'position' = @{
      'latitude' = '0'
      'longitude' = '0'
      'precision' = '0'
      'altitude' = '0'
  }
}
$result = @{
  'position' = @{
      'latitude' = ''
      'longitude' = ''
      'precision' = '0'
      'altitude' = '0'
  }
}
$company = '' #company name
$cdomain = '' #company domain
$mdomain = '' #user's upn suffix

##################
Get-Command '*json'

#Console User Loggined
$username = query user /server:localhost
$manuname = Get-CimInstance -ClassName Win32_ComputerSystem
$domain = $manuname.Domain
$username = $username -match 'console'
if ($username -ne $null) {
    $username = $username -replace '\s+','!'
    $username = $username -split '!'
    }
else{$username='system'}
#$username

#Get white IP information
$ipinf =  (Invoke-RestMethod http://ip-api.com/json/)
$dtcs=$dtcs+$ipinf.query

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



if (($null -ne ($ownips | ? { $ip -match $_ }))) {
    $ip=$ip+' '+$company
    $satVisible='&satVisible=99'
    $dtcs='&dtcs='+$company+' IP'
    $result=$tresult
}

else{
try{
if ($warr.Item(0) -ne $null){
    $wifiadd = ', "wifi_networks": [ '
    ForEach ($item in $warr){
        $warr.Item($i)
        $wifiadd = $wifiadd + '{"mac": "'+$warr.Item($i)+'", "signal_strength": "'+$wsarr.Item($i)+'", "age": 500},'
        $i= $i+1
        }
    $wifiadd = $wifiadd -replace ".{1}$"
    $wifiadd = $wifiadd + ']'
    $yarnd = Get-Random -Maximum $yaapikey.Count
    $Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey[$yarnd]+'"}, "ip": {"address_v4": "'+$ip+'"}'+$wifiadd+'}'
    $Uri = "https://api.lbs.yandex.net/geolocation/"
    $result = Invoke-RestMethod -Uri $Uri -Method Post -Body $Body -Verbose
    $result | ConvertTo-Json
    $result.position.latitude = $result.position.latitude -replace ',','.'
    $result.position.longitude = $result.position.longitude -replace ',','.'
    $ip=$ip+' yandex locator'
    }
    else{
    $ipgeokeyrnd = Get-Random -Maximum $ipgeokey.Count
    $uri = 'https://api.ipgeolocation.io/ipgeo?apiKey='+$ipgeokey[$ipgeokeyrnd]+'&ip='+$ip
    $ipgresult = Invoke-RestMethod -Uri $Uri -Method Get
    $ipgresult | ConvertTo-Json
    $result.position.latitude = $ipgresult.latitude
    $result.position.longitude = $ipgresult.longitude
    $ip=$ip+' ipgeolocation.io'
    }
}
catch {
    $ipgeokeyrnd = Get-Random -Maximum $ipgeokey.Count
    $uri = 'https://api.ipgeolocation.io/ipgeo?apiKey='+$ipgeokey[$ipgeokeyrnd]+'&ip='+$ip
    $ipgresult = Invoke-RestMethod -Uri $Uri -Method Get
    $ipgresult | ConvertTo-Json
    $result.position.latitude = $ipgresult.latitude
    $result.position.longitude = $ipgresult.longitude
    $ip=$ip+' ipgeolocation.io'
}
}

###custom ip block, can be copied
if ($ipinf.query -eq '') { #ip for location custom
    $ip=$company+' производство '+$ipinf.query
    $satVisible='&satVisible=99'
    $dtcs='&dtcs='+$company+' IP'
    $result = @{
        'position' = @{
           'latitude' = ''
           'longitude' = ''
           'precision' = ''
           'altitude' = '0'
  }
}
}

#Disable accuraty if precision to hight
if ($result.position.precision -gt 4000) {$result.position.precision=0}

#Calculate unix seconds timestamp
$date1 = Get-Date -Date "01/01/1970"
$date2 = [System.DateTime]::UtcNow
$ts=[int](New-TimeSpan -Start $date1 -End $date2).TotalSeconds

#Check charge and power, processing for pc
$tbmpbatt=Get-CimInstance -ClassName Win32_Battery
$charge=$tbmpbatt.EstimatedChargeRemaining
$ac = (Get-WmiObject -Class BatteryStatus -Namespace root\wmi -ComputerName "localhost").PowerOnLine
if ($charge -eq $null) {$charge = 100} 
if (($ac -eq $null) -or ($ac -eq 'True')) {$ac = 'AC'} else {$ac = 'Battery'}
$charge = [int]$charge
if ($charge -is [int]) {
} 
else{
    $charge = ''
}

$eastruntime=$tbmpbatt.EstimatedRunTime
$battstatus=$tbmpbatt.Status
if ($eastruntime -is [int]) {

} 
else{
    $eastruntime = ''
}




[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
$networkInterfaceAlias=''
$net_name=''
$netsh = netsh wlan sh int | Select-String signal,ssid,сигнал

$ssid = $netsh.Item(0)
$ssid = $ssid -replace 'SSID',''
$ssid = $ssid -replace ':',''
$ssid = $ssid -replace '\s',''

$signal = $netsh.Item(2)
$signal = $signal -replace 'Сигнал',''
$signal = $signal -replace ':',''
$signal = $signal -replace '\s',''
$signal = $signal -replace '%',''


$network = Get-NetConnectionProfile
#$network | ConvertTo-Json


$computer = 'localhost'
        $user = $null 
        $lockuser = ''
        $lckuser = $null
        $userstatus = $null

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
    catch { if ($user) { 
#    "$user logged on"; $userstatus='logged on'
    } } 
    } 
$tmpdid = gwmi -Class win32_computersystem -ComputerName $computer
$deviceid = $tmpdid.Name+'.'+$tmpdid.Domain


if (($user -eq $null) -and ($userstatus -eq $null)){
    $rdp = QUERY SESSION
    $rdp = $rdp  -replace "\s+", ";"
    $rdp = $rdp  -replace "Active", "Активно"
    $rdp = $rdp -match 'rdp-tcp#'
    $rdp = $rdp -match 'Активно'
    $rdp = $rdp | ConvertFrom-Csv -Delimiter ';' -Header 'session','user','id','status' 
    
    if (($rdp[0].user -ne '') -and ($rdp[0].user -ne $null)){
        $user = $rdp[0].user
        if ($user -match 'rdp-tcp'){$user = $rdp[0].id}
        $userstatus = "logged rdp"
    }
}
if ($user -notmatch $cdomain+'\\'){$user = $cdomain+'\'+$user}
if ($userstatus -eq $null){$userstatus='dont login'}

$user=$user.ToLower()
#$manuname.PCSystemType
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

if ($manuname.SystemFamily -ne '') {$SystemFamily = '&versionHw='+$manuname.SystemFamily}
if ($manuname.NumberOfProcessors -ne '') {$NumberOfProcessors = '&NumberOfProcessors='+$NumberOfProcessors.Model}
if ($eastruntime -ne '') {$eastruntime = '&eastruntime='+$eastruntime}
if ($battstatus -ne '') {$battstatus = '&battstatus='+$battstatus}

$result.position.altitude = '&altitude='+$result.position.altitude
if ($ipinf.zip -ne '') {$ipinf.zip = '&zip='+$ipinf.zip}
if ($ipinf.isp -ne '') {$ipinf.isp = '&operator='+$ipinf.isp}
try{
if ($user -ne '') {$login = '&username='+$user}
if (($username.Item(7) -ne $null) -and ($username.Item(7) -ne 'system')) {$logt = '&logintime='+$username.Item(6)+' '+$username.Item(7)}
} catch {}
if ($domain -ne '') {$domain = '&domain='+$domain}
if ($ssid -ne '') {$ssid = '&ssid='+$ssid}
if ($signal -ne '') {$signal = '&rssi='+$signal}
if ($network.InterfaceAlias -ne $null) {$networkInterfaceAlias = '&InterfaceAlias='+$network.InterfaceAlias}
if ($network.Name -ne $null) {$networkName = '&net_name='+$network.Name}
if ($userstatus -ne '') {$userstat = '&status='+$userstatus}
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
#$localip | ConvertTo-Json
if ($localip.IPAddress -ne '') {$localip = '&localIP='+$localip.IPAddress}

$deviceid=$deviceid.ToLower()

$uri= $srvproto+'://'+$server+'/?id='+$deviceid+'&timestamp='+$ts+'&lat='+$result.position.latitude+'&lon='+$result.position.longitude+$result.position.altitude+'&realip='+$ip+$charge+$ipinf.isp+'&power='+$ac+'&accuracy='+$result.position.precision+'&vin='+$deviceid+$ipinf.zip+$login+$domain+$logt+$ssid+$signal+$networkName+$userstat+$lckuser+$networkInterfaceAlias+'&versionFw='+$ver+$localip+'&channel=local_script'+$PCSystemType+$SystemFamily+$eastruntime+$battstatus+$dtcs+$Ignition+$satVisible
$debug=''

try{
Invoke-RestMethod -Uri $uri -Method 'Get'-ContentType 'application/x-www-form-urlencoded'
}
                    catch  {
                    $tlogin=$user
                    $tmpcdomain=$cdomain+'\\'
                    $tlogin = $tlogin -replace $tmpcdomain.ToLower(),''
                    $tlogin = $tlogin -replace $tmpcdomain.ToUpper(),''

                    $body = '{"name": "'+$tlogin+$mdomain+'","uniqueId": "'+$deviceid+'","disabled": false,"positionId": 0,"groupId": 2,"attributes": {}}'
                    Invoke-RestMethod -Headers @{Authorization=("Basic {0}" -f $base64)} -Uri $apiUri  -Method 'Post' -Body $body -ContentType 'application/json'
                    }
