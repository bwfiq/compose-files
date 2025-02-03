This repository is only for CONFIGURATION files. Do not use it to back up the actual volumes.

The gitignore ignores all files in any directory named data recursively.
Map the docker compose volumes to a ./data subdirectory on the host to make use of this.
Add the following to each compose file to monitor it for updates with diun:
```yml
services:
  [container name]:
    labels:
      - diun.enable=true
```

Naming convention for containers are [private|public]-[image-name].

Secrets needed on your local machine (at `/run/secrets/`):
- `cloudflare-api-token`: used by the swag container to set the cloudflare api token for dns validation
- `diun-telegram-bot-token` and `diun-telegram-chat-ids`: used by diun to send notifications to telegram

# Containers
- [SWAG](https://github.com/linuxserver/docker-swag) as reverse proxy
  - Includes a startup script that pulls in a cloudflare api token as a secret
- [DIUN](https://github.com/crazy-max/diun) as image update notifier
  - Monitors for updates and sends telegram message

# TODO
- [ ] add a check for the network top level element in the compose files
- [x] add monitoring for container updates 
- [ ] add monitoring for swag proxy sample updates
- [ ] add authelia for MFA
