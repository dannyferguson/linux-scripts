#!/bin/bash
set -euo pipefail

#################################################
#
#     Configuration (change these as needed)
#
#################################################
LOG_FILE="ufw-cloudflare.log"
# Set the URL that returns the text file with IPv4 addresses
URL="https://www.cloudflare.com/ips-v4/#"

#################################################
#
#     Dont touch anything below this unless
#          you know what you are doing!
#
#################################################
log() {
  echo "[$(date "+%Y-%m-%d %H:%M:%S")][ufw-cloudflare.sh]: $1" | tee -a "$LOG_FILE"
}

# Fetch the text file from the URL
curl -s "$URL" > ipv4_list.txt

# Loop through the IPv4 addresses and add them to the firewall
while read -r ip; do
    ufw allow from "$ip" comment 'Cloudflare' > /dev/null
    log "Added $ip to the firewall"
done < ipv4_list.txt

# Clean up the temporary file
rm ipv4_list.txt
