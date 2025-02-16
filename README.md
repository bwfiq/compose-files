This repository is only for CONFIGURATION files. Do not use it to back up the actual volumes.

Create a docker network named `apollo_bridge`.

The gitignore ignores all files in any directory named data recursively.
Map the docker compose volumes to a ./data subdirectory on the host to make use of this.
Add the following to each compose file under the services top level element -> the service to monitor it for updates with diun:

```yml
services:
  [container name]:
    labels:
      - diun.enable=true
```

Naming convention for containers are [private|public]-[image-name]. While there is no functional difference between a public and private service, this naming convention allows us to easily see what services are proxied by swag.

Some of the compose files require secrets that will be loaded from files in your /run/secrets. You must ensure these files do not end in a newline, meaning you cannot simply `echo $VAR > /run/secrets/VAR` as it will result in issues when a script or service tries to parse the file. The recommended method of doing this is:

```bash
printf "%s" "$(openssl rand -base64 32 | tr -d '\n')" > /run/secrets/WAKAPI_PASSWORD_SALT
```

Secrets:

- DIUN
  - `diun-telegram-bot-token` and `diun-telegram-chat-ids`: used by diun to send notifications to telegram
- LLDAP
  - `LLDAP_JWT_SECRET`: used by lldap as a JWT signature secret. Generate with `LC_ALL=C tr -dc 'A-Za-z0-9!#%&()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 32`
  - `LLDAP_KEY_SEED`: used by lldap to generate the private key file. Use any string of at least 12 characters.
  - `LLDAP_LDAP_USER_PASS`: used by lldap for the default admin account password. Use any secure password.
- SWAG
  - `cloudflare-api-token`: used by the swag container to set the cloudflare api token for dns validation
- Hoarder
  - `nextauth_secret`: used by Hoarder. Generate with `openssl rand -base64 36`
  - `meili_master_key`: used by Hoarder. Generate with `openssl rand -base64 36`
  - `openai_api_key`: used by Hoarder. Get from [OpenAI's platform](https://platform.openai.com/settings/organization/api-keys)
- Wakapi
  - `WAKAPI_PASSWORD_SALT`: used by Wakapi to hash passwords. Generate with `openssl rand -base64 36`

# Containers

- [DIUN](https://github.com/crazy-max/diun) as image update notifier
  - Monitors for updates and sends telegram message
- [LLDAP](https://github.com/lldap/lldap) as LDAP server
  - lightweight LDAP server
  - Internal ports: 3890 (LDAP), 17170 (web UI)
  - External ports: 17170 (web UI)
- [SWAG](https://github.com/linuxserver/docker-swag) as reverse proxy
  - Includes a startup script that pulls in a cloudflare api token as a secret
  - Internal ports: 443 (reverse proxy)
  - External ports: 443 (reverse proxy)
  - Proxies configured:
    - `caprover.*`/`*.caprover.*` (192.168.0.180:3000), `pairdrop.*` (pairdrop:3000), `hoarder.*` (hoarder:3000), `grocy.*` (grocy:80)
  - fail2ban jail [nginx-unauthorized] was _REMOVED_ because it kept banning ips coming from its own public ip
- [Grocy](https://github.com/grocy/grocy) for household management
  - Internal ports: 80 (HTTP)
- [Hoarder](https://github.com/hoarder-app/hoarder) as bookmark manager
  - Collects and archives web pages
  - Includes a startup script that sets the environment variables from secrets
  - Internal ports: 3000
- [Wakapi](https://github.com/muety/wakapi) as time tracker
  - Monitors your tools/browsers and collects metrics about your activity
  -

# GitHub Actions Workflows

## Deploy

This GitHub Actions workflow automates the deployment of your application to a server whenever changes are pushed to the `main` branch of your repository. It connects to the Tailscale network and pulls the latest code from the repository to the target server.

Secrets Configuration:
You need to define several secret values in your GitHub repository settings. Go to your repository, click on "Settings" > "Secrets and variables" > "Actions", then add the following secrets:

- `TS_OAUTH_CLIENT_ID`: Your Tailscale OAuth client ID.
- `TS_OAUTH_SECRET`: Your Tailscale OAuth secret.
- `SERVER_USER`: The username to log in to your server.
- `SERVER_HOST`: The hostname or IP address of your server.
- `SERVER_PASSWORD`: The password for your server user.
- `SERVER_DIRECTORY`: The directory you are using for your compose files.

Once everything is configured, push changes to the `main` branch of your repository. This will trigger the workflow, which:

1. Checks out the code.
2. Connects to the Tailscale VPN.
3. SSHs into the target server.
4. Pulls the latest code from the repository.

Monitor the Actions tab in your repository for logs and status of the deployments.

# TODO

- [x] add monitoring for container updates
- [ ] add allow and deny to nginx confs
- [ ] add a check for the network top level element in the compose files
- [ ] add monitoring for swag proxy sample updates
- [ ] add authelia for MFA
- [ ] change network name

# Misc

Another machine on the LAN is running caprover with these commands:

```bash
mkdir -p /captain/data/

echo "{"skipVerifyingDomains":"true","nginxPortNumber80":8080,"nginxPortNumber443":8443}" > /captain/data/config-override.json

docker run -p 3000:3000
-e ACCEPTED_TERMS=true
-e BY_PASS_PROXY_CHECK=true
-e MAIN_NODE_IP_ADDRESS=127.0.0.1
-v /var/run/docker.sock:/var/run/docker.sock -v /captain:/captain caprover/caprover
```
