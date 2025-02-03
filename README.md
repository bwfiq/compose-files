This repository is only for CONFIGURATION files. Do not use it to back up the actual volumes.

The gitignore ignores all files in any directory named data recursively.
Map the docker compose volumes to a ./data subdirectory on the host to make use of this.

Naming convention for containers are [private|public]-[image-name].

Secrets needed on your local machine (at /run/secrets/):
- cloudflare-api-token: used by the swag container to set the cloudflare api token for dns validation

# Containers
- [SWAG](https://github.com/linuxserver/docker-swag) as reverse proxy
  - Includes a startup script that pulls in a cloudflare api token as a secret
