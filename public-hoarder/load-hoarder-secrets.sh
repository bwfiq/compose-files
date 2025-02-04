#!/bin/sh
echo "Loading env vars from secrets..."

# Load the OpenAI API key from the secret file and export it as an environment variable
export NEXTAUTH_SECRET=$(cat /run/secrets/nextauth_secret)
export MEILI_MASTER_KEY=$(cat /run/secrets/meili_master_key)
export OPENAI_API_KEY=$(cat /run/secrets/openai_api_key)

# Execute the original command (/init)
# grepped from `docker inspect --format='{{.Config.Entrypoint}}' ghcr.io/hoarder-app/hoarder:release`
exec /init
