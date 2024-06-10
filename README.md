you can use laptoplocation.ps1 for track you windows-devices with traccar, but you must use https://github.com/apnagaev/trackmiddle for correct work
start script (can use with scheduler)
```
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\laptoplocation.ps1"
```
you must change $server=$server to $server="youre trackmiddle  server address"
