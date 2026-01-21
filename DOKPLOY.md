# Deploying Clawdbot to Dokploy

This guide explains how to deploy Clawdbot to [Dokploy](https://dokploy.com), a self-hosted PaaS alternative to Heroku/Vercel.

## Prerequisites

- Dokploy installed on your server
- Git repository access configured in Dokploy

## Deployment Steps

### 1. Create a Docker Compose Service

1. In Dokploy, go to **Projects** → **Create Project**
2. Inside the project, click **Create Service** → **Docker Compose**
3. Configure the Git source:
   - **Repository**: Your fork URL (e.g., `https://github.com/yourusername/clawdbot`)
   - **Branch**: `main`

### 2. Configure Compose Settings

In the **General** tab:
- **Compose Path**: `docker-compose.dokploy.yml`

### 3. Set Environment Variables

Go to the **Environment** tab and add:

```env
CLAWDBOT_GATEWAY_TOKEN=<generate with: openssl rand -hex 32>
ANTHROPIC_API_KEY=<your Anthropic API key>
```

See `.env.dokploy.example` for all available variables.

### 4. Configure Domain (Optional)

In the **Domains** tab:
- Add your domain pointing to the service
- Dokploy will configure Traefik automatically
- The gateway runs on port `18789`

### 5. Deploy

Click **Deploy** in the General tab.

## Post-Deployment

### First-Time Setup

After deployment, you need to run the onboarding wizard once:

```bash
# SSH into your Dokploy server
docker exec -it <container_name> node dist/index.js onboard
```

Or use Dokploy's **Terminal** feature in the Advanced tab.

### Accessing the Gateway

- **Web UI**: `https://your-domain.com` (if domain configured)
- **Direct**: `http://your-server-ip:18789`

Use your `CLAWDBOT_GATEWAY_TOKEN` to authenticate in the Control UI.

### Health Check

```bash
docker exec -it <container_name> node dist/index.js health --token "$CLAWDBOT_GATEWAY_TOKEN"
```

## Volume Backups

The deployment uses Docker named volumes:
- `clawdbot-config`: Configuration and credentials
- `clawdbot-workspace`: Agent workspace files

Configure **Volume Backups** in Dokploy to back these up to S3.

## Troubleshooting

### Build Fails
- Check the deployment logs in Dokploy
- Ensure the server has enough memory (recommended: 2GB+)

### Container Won't Start
- Verify `CLAWDBOT_GATEWAY_TOKEN` is set
- Check logs: Dokploy → Logs tab

### Can't Connect to Gateway
- Ensure port 18789 is exposed
- Check domain/Traefik configuration
