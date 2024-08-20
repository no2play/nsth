#!/bin/bash

# Define variables
TOKEN="token" # Replace this with your actual token
TOKEN_FILE="./com.sentinelone.registration-token"
INSTALLER_PKG="./Sentinel-Release-24-1-3-7587_macos_v24_1_3_7587.pkg" # Replace with the actual installer package name
TMP_DIR="/tmp"

# Create the token file and write the token to it
echo "$TOKEN" > "$TOKEN_FILE"

# Copy the token file and installer package to /tmp
sudo cp "$TOKEN_FILE" "$TMP_DIR"
sudo cp "$INSTALLER_PKG" "$TMP_DIR"

# Change ownership of the token file in /tmp to root
sudo chown root "$TMP_DIR/$(basename $TOKEN_FILE)"

# Run the installer from /tmp
sudo /usr/sbin/installer -pkg "$TMP_DIR/$(basename $INSTALLER_PKG)" -target /

echo "Installation completed."

