#!/bin/bash

# Check if the Docker secret is available
if [ -f /run/secrets/cloudflare-api-token ]; then
    echo "Updating cloudflare.ini with the Cloudflare API token"

    # Read the secret from the mounted file
    CLOUDFLARE_API_TOKEN=$(cat /run/secrets/cloudflare-api-token)

    # Clear the cloudflare.ini file and write the new token
    echo "dns_cloudflare_api_token = $CLOUDFLARE_API_TOKEN" > /config/dns-conf/cloudflare.ini
else
    echo "Cloudflare API token secret not found!"
fi

# Call the original init script to start the main service
exec /init
