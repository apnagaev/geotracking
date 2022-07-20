
#############ChangeMe##################
$server='geo.whereit.ru'
$srvport=':45055'
$srvproto='https'
$yaapikey='AFiL1mIBAAAAElgNcwIAXjg8FRcwCU0YrS3kBXSc9r_Vxf4AAAAAAAAAAAANOb4FxMaibmz6A9WREh4-y4bqhw=='
##################

$deviceid=[System.Net.Dns]::GetHostByName($env:computerName).HostName


#Console User Loggined
$username = query user /server:localhost
$username
$username = $username -match 'console'
if ($username -ne $null) {
$username = $username -replace '\s+','!'
$username = $username -split '!'
$username = $username.Item(1)+'-'+$username.Item(6)+'-'+$username.Item(7)
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


#Make json for yandex-locator request (need optimize)
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "ip": {"address_v4": "'+$ipinf.query+'"}}'
if ($wsarr.Item(0) -ne $null){
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "wifi_networks": [ {"mac": "'+$warr.Item(0)+'", "signal_strength": '+$wsarr.Item(0)+', "age": 500} ], "ip": {"address_v4": "'+$ipinf.query+'"}}'
}
if ($wsarr.Item(1) -ne $null){
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "wifi_networks": [ {"mac": "'+$warr.Item(0)+'", "signal_strength": '+$wsarr.Item(0)+', "age": 500}, {"mac": "'+$warr.Item(1)+'", "signal_strength": '+$wsarr.Item(1)+', "age": 500} ], "ip": {"address_v4": "'+$ipinf.query+'"}}'
}
if ($wsarr.Item(2) -ne $null){
$Body = 'json={"common": {"version": "1.0", "api_key": "'+$yaapikey+'"}, "wifi_networks": [ {"mac": "'+$warr.Item(0)+'", "signal_strength": '+$wsarr.Item(0)+', "age": 500}, {"mac": "'+$warr.Item(1)+'", "signal_strength": '+$wsarr.Item(1)+', "age": 500}, {"mac": "'+$warr.Item(2)+'", "signal_strength": '+$wsarr.Item(2)+', "age": 500} ], "ip": {"address_v4": "'+$ipinf.query+'"}}'
}


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
if (($ac -eq $null) -or ($ac -eq 'True')) {$ac = 'Ac'} else {$ac = 'Battery'}

#http-get to geoserver
$uri= $srvproto+'://'+$server+$srvport+'/?id='+$deviceid+'&timestamp='+$ts+'&lat='+$result.position.latitude+'&lon='+$result.position.longitude+'&realip='+$ipinf.query+'&zip='+$ipinf.zip+'&batt='+$charge+'&isp='+$ipinf.isp+'&power='+$ac+'&accuracy='+$result.position.precision+'&computer_name='+$deviceid+'&username='+$username
Invoke-WebRequest -Uri $uri

#Write vars
write('DeviceID='+$deviceid)
write('Username='+$username)
write('timestamp='+$ts)
write('latitude='+$result.position.latitude)
write('longitude='+$result.position.longitude)
write('Charge='+$charge)
write('Power='+$ac)
write('URL='+$uri)
