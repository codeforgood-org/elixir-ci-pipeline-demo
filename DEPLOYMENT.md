# Deployment Guide

This guide covers various deployment strategies for the Task Manager application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Docker Deployment](#docker-deployment)
- [Fly.io Deployment](#flyio-deployment)
- [Render Deployment](#render-deployment)
- [DigitalOcean Deployment](#digitalocean-deployment)
- [AWS Deployment](#aws-deployment)
- [Health Checks](#health-checks)
- [Monitoring](#monitoring)
- [Scaling](#scaling)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying, ensure you have:

- A PostgreSQL database (version 15 or later)
- Generated a secure `SECRET_KEY_BASE`
- Configured all required environment variables
- Tested the application locally

### Generating Secrets

```bash
# Generate SECRET_KEY_BASE
mix phx.gen.secret

# Generate a 64-byte random string
openssl rand -base64 64
```

## Environment Variables

### Required Variables

```bash
DATABASE_URL=ecto://user:password@host:5432/database_name
SECRET_KEY_BASE=your_secret_key_base_at_least_64_bytes
PHX_HOST=your-domain.com
PORT=4000
```

### Optional Variables

```bash
POOL_SIZE=10
ECTO_IPV6=false
MIX_ENV=prod
```

## Docker Deployment

### Using Docker Compose

The simplest way to deploy is using Docker Compose:

```bash
# 1. Clone the repository
git clone https://github.com/codeforgood-org/elixir-ci-pipeline-demo.git
cd elixir-ci-pipeline-demo

# 2. Create .env file
cp .env.example .env
# Edit .env with your production values

# 3. Build and start
docker-compose up -d

# 4. Run migrations
docker-compose exec web mix ecto.migrate

# 5. Check logs
docker-compose logs -f web
```

### Using Docker Standalone

```bash
# 1. Build the image
docker build -t task-manager:latest .

# 2. Run PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgres:15

# 3. Run the application
docker run -d \
  --name task-manager \
  --link postgres \
  -e DATABASE_URL=ecto://postgres:postgres@postgres/task_manager_prod \
  -e SECRET_KEY_BASE=your_secret_key \
  -e PHX_HOST=localhost \
  -p 4000:4000 \
  task-manager:latest

# 4. Run migrations
docker exec task-manager /app/bin/task_manager eval "TaskManager.Release.migrate"
```

## Fly.io Deployment

Fly.io offers excellent Elixir support with global deployment.

### Setup

```bash
# 1. Install flyctl
curl -L https://fly.io/install.sh | sh

# 2. Login
fly auth login

# 3. Launch app (from project directory)
fly launch

# 4. Set secrets
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)

# 5. Deploy
fly deploy

# 6. Run migrations
fly ssh console
/app/bin/task_manager eval "TaskManager.Release.migrate"
```

### fly.toml Configuration

```toml
app = "task-manager"
primary_region = "sjc"

[build]
  dockerfile = "Dockerfile"

[env]
  PHX_HOST = "task-manager.fly.dev"
  PORT = "8080"

[[services]]
  http_checks = []
  internal_port = 8080
  protocol = "tcp"
  script_checks = []

  [services.concurrency]
    hard_limit = 1000
    soft_limit = 1000
    type = "connections"

  [[services.ports]]
    force_https = true
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    grace_period = "30s"
    interval = "15s"
    restart_limit = 0
    timeout = "2s"

  [[services.http_checks]]
    interval = 10000
    grace_period = "5s"
    method = "get"
    path = "/health"
    protocol = "http"
    timeout = 2000
    tls_skip_verify = false
```

## Render Deployment

Render provides simple deployment with automatic SSL.

### Steps

1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Configure:
   - **Build Command**: `mix deps.get && mix compile && mix assets.deploy`
   - **Start Command**: `mix phx.server`
   - **Environment**: `Elixir`

4. Add environment variables:
   ```
   SECRET_KEY_BASE=<generated-secret>
   DATABASE_URL=<postgres-connection-string>
   PHX_HOST=your-app.onrender.com
   MIX_ENV=prod
   ```

5. Add a PostgreSQL database
6. Deploy!

## DigitalOcean Deployment

### Using DigitalOcean App Platform

1. Create new app from GitHub repository
2. Select Elixir as runtime
3. Configure environment variables
4. Add PostgreSQL database
5. Deploy

### Using Droplet (VPS)

```bash
# 1. SSH into your droplet
ssh root@your-droplet-ip

# 2. Install dependencies
apt-get update
apt-get install -y postgresql postgresql-contrib nginx certbot

# 3. Install Elixir and Erlang
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
dpkg -i erlang-solutions_2.0_all.deb
apt-get update
apt-get install -y esl-erlang elixir

# 4. Clone and build
git clone https://github.com/codeforgood-org/elixir-ci-pipeline-demo.git
cd elixir-ci-pipeline-demo
mix local.hex --force
mix local.rebar --force
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release

# 5. Configure systemd service
# Create /etc/systemd/system/task_manager.service
# See systemd service example below

# 6. Start service
systemctl enable task_manager
systemctl start task_manager
```

### Systemd Service

Create `/etc/systemd/system/task_manager.service`:

```ini
[Unit]
Description=Task Manager Phoenix App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/task_manager
Environment=PORT=4000
Environment=MIX_ENV=prod
Environment=SECRET_KEY_BASE=your_secret_key
Environment=DATABASE_URL=your_database_url
ExecStart=/opt/task_manager/_build/prod/rel/task_manager/bin/server
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

## AWS Deployment

### Using Elastic Beanstalk

1. Install EB CLI: `pip install awsebcli`
2. Initialize: `eb init`
3. Create environment: `eb create production`
4. Set environment variables: `eb setenv SECRET_KEY_BASE=xxx`
5. Deploy: `eb deploy`

### Using ECS (Elastic Container Service)

1. Push Docker image to ECR
2. Create ECS cluster
3. Create task definition using your image
4. Create service
5. Configure load balancer
6. Set up RDS PostgreSQL instance

### Using EC2

Similar to DigitalOcean Droplet deployment above.

## Health Checks

The application provides health check endpoints for monitoring:

```bash
# Simple health check
curl https://your-domain.com/health

# Detailed health check (includes database connectivity)
curl https://your-domain.com/health/detailed
```

### Load Balancer Configuration

Configure your load balancer to use the health check endpoint:

- **Path**: `/health`
- **Port**: `4000` (or your configured port)
- **Protocol**: HTTP
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy threshold**: 2
- **Unhealthy threshold**: 3

## Monitoring

### Application Monitoring

Consider integrating:

- **AppSignal**: Elixir-native monitoring
- **New Relic**: Full-stack monitoring
- **Sentry**: Error tracking
- **Datadog**: Infrastructure monitoring

### Database Monitoring

- Monitor query performance
- Set up slow query logs
- Monitor connection pool usage
- Track database size

### Log Aggregation

- **Logflare**: Elixir-friendly logging
- **Papertrail**: Log management
- **CloudWatch Logs**: For AWS deployments

## Scaling

### Horizontal Scaling

The application is stateless and can be scaled horizontally:

```bash
# Docker Compose
docker-compose up --scale web=3

# Fly.io
fly scale count 3

# Render
# Use dashboard to adjust instance count
```

### Vertical Scaling

Increase resources per instance:

```bash
# Fly.io
fly scale vm dedicated-cpu-1x

# Adjust POOL_SIZE for database connections
export POOL_SIZE=20
```

### Database Scaling

- Use connection pooling (configured by default)
- Consider read replicas for read-heavy workloads
- Implement caching (Redis/Memcached)
- Use database connection proxy (PgBouncer)

## SSL/TLS Configuration

### Using Certbot (for VPS deployments)

```bash
# Install Certbot
apt-get install certbot python3-certbot-nginx

# Obtain certificate
certbot --nginx -d your-domain.com

# Auto-renewal
certbot renew --dry-run
```

### Nginx Configuration

```nginx
upstream phoenix {
  server 127.0.0.1:4000;
}

server {
  listen 80;
  server_name your-domain.com;
  return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl http2;
  server_name your-domain.com;

  ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

  location / {
    proxy_pass http://phoenix;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
  }
}
```

## Backup Strategy

### Database Backups

```bash
# Manual backup
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# Automated daily backups
crontab -e
# Add: 0 2 * * * pg_dump $DATABASE_URL > /backups/backup_$(date +\%Y\%m\%d).sql
```

### Application Backups

- Keep Docker images versioned
- Tag releases in Git
- Maintain database migrations history

## Troubleshooting

### Application Won't Start

1. Check logs: `docker-compose logs web` or `journalctl -u task_manager`
2. Verify environment variables
3. Test database connectivity: `psql $DATABASE_URL`
4. Check port availability: `netstat -tulpn | grep 4000`

### Database Connection Issues

1. Verify DATABASE_URL format
2. Check PostgreSQL is running
3. Verify network connectivity
4. Check connection pool size

### High Memory Usage

1. Reduce POOL_SIZE if too high
2. Check for memory leaks in logs
3. Monitor with observer: `iex --name debug@127.0.0.1 --cookie <cookie>`

### Performance Issues

1. Enable query logging
2. Check database indexes
3. Review N+1 query patterns
4. Monitor with LiveDashboard
5. Use :telemetry for custom metrics

## Rolling Back

### Docker

```bash
# Rollback to previous version
docker-compose down
docker-compose up -d --build

# Or use specific tag
docker pull task-manager:v1.0.0
docker-compose up -d
```

### Fly.io

```bash
fly releases
fly deploy --image task-manager:v1.0.0
```

### Database Rollback

```bash
# Rollback last migration
mix ecto.rollback

# Rollback to specific version
mix ecto.rollback --to 20240101000000
```

## Security Checklist

- [ ] SECRET_KEY_BASE is properly randomized and secure
- [ ] Database credentials are not in source control
- [ ] SSL/TLS is enabled
- [ ] Security headers are configured
- [ ] Rate limiting is implemented (if needed)
- [ ] CORS is properly configured (if needed)
- [ ] Database backups are automated
- [ ] Monitoring and alerting are set up
- [ ] Health checks are configured
- [ ] Firewall rules are properly set

## Post-Deployment

1. Verify health checks are passing
2. Run smoke tests against production
3. Monitor error rates and performance
4. Test key user flows
5. Verify database migrations completed
6. Check SSL certificate validity
7. Test backup and restore procedures

---

For additional help, consult:
- [Phoenix Deployment Guides](https://hexdocs.pm/phoenix/deployment.html)
- [Fly.io Elixir Guide](https://fly.io/docs/elixir/)
- [Render Elixir Guide](https://render.com/docs/deploy-elixir)
