# About this repo

This is collection of Tools and documents use for PoC.

# For Akamai datastream custom HTTPS endpoint

To run script in background
Terminate existing script process:

```bash
ps aux | grep {Script name}
kill {Script PID}
```

Run the script in background

```bash
sudo nohup python3 akamai_fw_datastream_cef.py &
```

# Scripts/Encrypt - Ransomeware simulation file

- Download Simulated-Ransomware.zip and extract the EXE file.
- Run the EXE file to start encryption process.
[ This will encrypt files only in the C:\temp directory. To modify the script, you should download the PowerShell version and convert your customized ps1 to an EXE file instead.]

## Using ps2exe tool with your customized ps1 script ##

Run Powershell as administrator and install ps2exe
```bash
Install-Module ps2exe
```

Run ps2exe to convert ps1 to exe file
```bash
ps2exe .\Simulated-Ransomware.ps1 .\Simulated-Ransomware.exe -noConsole
```
