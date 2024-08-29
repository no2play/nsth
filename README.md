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

# For Encryption process

- Download Simulated-Ransomware.zip and extract the EXE file.
- Run the EXE file to start encryption process.

NOTE: It will encrypt file on C:\temp only
