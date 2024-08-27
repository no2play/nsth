# About this repo

This is collection of Tools and documents use for PoC.

# For Akamai datastream

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

