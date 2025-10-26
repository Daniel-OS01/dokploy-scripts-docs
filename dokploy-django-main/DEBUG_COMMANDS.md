# 🛠️ Essential Debug Commands for Dokploy Django

**Quick reference for debugging Docker containers, databases, and Django apps**

## 📦 Docker Container Commands

### List Containers

```bash
# Show running containers
docker ps

# Show all containers (including stopped)
docker ps -a

# Filter by name
docker ps | grep myapp
docker ps | grep django

# Show only container IDs
docker ps -q

# Show with custom format
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Container Logs

```bash
# View last 20 lines
docker logs <container-id> --tail 20

# View last 50 lines
docker logs <container-id> --tail 50

# Follow logs in real-time (Ctrl+C to exit)
docker logs <container-id> --follow

# Follow with timestamp
docker logs <container-id> --follow --timestamps

# View logs since specific time
docker logs <container-id> --since 5m    # Last 5 minutes
docker logs <container-id> --since 1h    # Last hour
docker logs <container-id> --since "2025-10-06T20:00:00"

# Combine: tail + follow
docker logs <container-id> --tail 30 --follow

# Save logs to file
docker logs <container-id> > container_logs.txt
```

### Execute Commands in Container

```bash
# Run Python shell
docker exec <container-id> python manage.py shell

# Run Django command
docker exec <container-id> python manage.py migrate
docker exec <container-id> python manage.py createsuperuser
docker exec <container-id> python manage.py collectstatic --noinput

# Interactive bash shell
docker exec -it <container-id> bash
docker exec -it <container-id> sh  # If bash not available

# Check Django settings
docker exec <container-id> python manage.py diffsettings
docker exec <container-id> python manage.py check

# One-liner Python commands
docker exec <container-id> python -c "import django; print(django.VERSION)"
```

### Inspect Container

```bash
# Full container details (JSON)
docker inspect <container-id>

# Get specific field
docker inspect <container-id> --format='{{.State.Status}}'
docker inspect <container-id> --format='{{.NetworkSettings.IPAddress}}'
docker inspect <container-id> --format='{{.Config.Env}}'

# View environment variables
docker exec <container-id> printenv
docker exec <container-id> printenv | grep DATABASE
docker exec <container-id> printenv | grep DJANGO

# Check container IP
docker exec <container-id> hostname -i

# Check running processes
docker exec <container-id> ps aux
```

### Container Resource Usage

```bash
# Show live stats (CPU, Memory)
docker stats

# Show stats for specific container
docker stats <container-id>

# Show once (no streaming)
docker stats --no-stream
```

### Container Network

```bash
# List all networks
docker network ls

# Inspect network
docker network inspect dokploy-network

# See which containers are on network
docker network inspect dokploy-network --format='{{range .Containers}}{{.Name}} {{end}}'
```

## 🐳 Docker Swarm / Service Commands

### Service Management

```bash
# List services
docker service ls

# List services with filter
docker service ls | grep myapp
docker service ls | grep django

# Detailed service info
docker service ps <service-name>
docker service ps myapp-backend-abc123

# Show service with error details
docker service ps <service-name> --no-trunc

# Service logs (aggregated from all replicas)
docker service logs <service-name>
docker service logs <service-name> --tail 50
docker service logs <service-name> --follow
```

### Service Inspection

```bash
# Inspect service
docker service inspect <service-name>

# Get service environment variables
docker service inspect <service-name> --format='{{.Spec.TaskTemplate.ContainerSpec.Env}}'

# Get service image
docker service inspect <service-name> --format='{{.Spec.TaskTemplate.ContainerSpec.Image}}'
```

## 🐍 Django-Specific Commands

### Database

```bash
# Check database connection
docker exec <container-id> python manage.py dbshell

# Run migrations
docker exec <container-id> python manage.py migrate

# Show migrations status
docker exec <container-id> python manage.py showmigrations

# Create migration
docker exec <container-id> python manage.py makemigrations

# SQL for migration (preview)
docker exec <container-id> python manage.py sqlmigrate app_name 0001
```

### Django Shell

```bash
# Start Django shell
docker exec -it <container-id> python manage.py shell

# Run Python one-liner
docker exec <container-id> python manage.py shell -c "from django.contrib.auth.models import User; print(User.objects.count())"

# Check specific setting
docker exec <container-id> python manage.py shell -c "from django.conf import settings; print('DEBUG:', settings.DEBUG)"
docker exec <container-id> python manage.py shell -c "from django.conf import settings; print('CSRF_TRUSTED_ORIGINS:', settings.CSRF_TRUSTED_ORIGINS)"
docker exec <container-id> python manage.py shell -c "from django.conf import settings; print('DATABASES:', settings.DATABASES)"
```

### User Management

```bash
# Create superuser
docker exec -it <container-id> python manage.py createsuperuser

# Change user password
docker exec -it <container-id> python manage.py changepassword username

# List users
docker exec <container-id> python manage.py shell -c "from django.contrib.auth.models import User; [print(u.username) for u in User.objects.all()]"
```

### Static Files

```bash
# Collect static files
docker exec <container-id> python manage.py collectstatic --noinput

# Find static files
docker exec <container-id> python manage.py findstatic admin/css/base.css
```

## 🐘 PostgreSQL Commands

### From VPS (Host)

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Connect to specific database
sudo -u postgres psql -d your_database

# List databases
sudo -u postgres psql -c "\l"

# List users
sudo -u postgres psql -c "\du"

# List tables in database
sudo -u postgres psql -d your_database -c "\dt"

# Check database size
sudo -u postgres psql -c "SELECT pg_size_pretty(pg_database_size('your_database'));"

# Check active connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE datname='your_database';"

# Kill connection
sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='your_database' AND pid <> pg_backend_pid();"
```

### From Container

```bash
# Test PostgreSQL connection
docker exec <container-id> python -c "
import psycopg2
conn = psycopg2.connect('postgresql://user:pass@172.17.0.1:5432/dbname')
print('✅ Connected!')
conn.close()
"

# Django database shell
docker exec -it <container-id> python manage.py dbshell
```

### PostgreSQL Logs

```bash
# View PostgreSQL logs (Ubuntu/Debian)
sudo tail -f /var/log/postgresql/postgresql-*-main.log

# Search for errors
sudo grep ERROR /var/log/postgresql/postgresql-*-main.log

# Search for connection issues
sudo grep "connection" /var/log/postgresql/postgresql-*-main.log
```

## 🔥 Traefik Debugging

```bash
# Check Traefik container
docker ps | grep traefik

# Traefik logs
docker logs dokploy-traefik --tail 50
docker logs dokploy-traefik --follow

# Check for errors
docker logs dokploy-traefik 2>&1 | grep -i error

# Check config files
ls -la /etc/dokploy/traefik/dynamic/

# Validate YAML syntax
docker exec dokploy-traefik cat /etc/dokploy/traefik/dynamic/your-app.yml

# Check Traefik networks
docker network inspect dokploy-network
```

## 🌐 nginx Debugging

```bash
# Check nginx status
sudo systemctl status nginx

# Test nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

# nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Search for errors
sudo grep "error" /var/log/nginx/error.log

# Check site config
cat /etc/nginx/sites-available/api.yourdomain.com

# List enabled sites
ls -la /etc/nginx/sites-enabled/
```

## 🔍 Quick Diagnostics

### Check Everything at Once

```bash
# Container health
docker ps | grep your-app

# Container logs (last errors)
docker logs <container-id> --tail 20 2>&1 | grep -i error

# Database connection from container
docker exec <container-id> python -c "import psycopg2; psycopg2.connect('postgresql://user:pass@172.17.0.1:5432/db'); print('DB OK')"

# Django settings
docker exec <container-id> python manage.py check

# Traefik status
docker logs dokploy-traefik --tail 10 2>&1 | grep -i error

# nginx status
sudo nginx -t && echo "nginx OK"
```

### Common Issue Checks

```bash
# Is container running?
docker ps | grep <container-name>

# Container crash loop?
docker ps -a | grep <container-name> | head -5

# What's the error?
docker logs <container-id> --tail 100 | grep -i error

# Database accessible?
docker exec <container-id> python manage.py dbshell

# Environment variables set?
docker exec <container-id> printenv | grep -E "SECRET_KEY|DATABASE|ALLOWED_HOSTS"

# Django settings loaded?
docker exec <container-id> python manage.py diffsettings | head -20

# Migrations applied?
docker exec <container-id> python manage.py showmigrations

# Can reach API?
curl -I https://api.yourdomain.com/api/
```

## 📝 Copy Files To/From Container

```bash
# Copy file TO container
docker cp local-file.txt <container-id>:/app/

# Copy file FROM container
docker cp <container-id>:/app/file.txt ./local-file.txt

# Copy directory
docker cp <container-id>:/app/logs ./container-logs/

# Copy database backup
docker cp <container-id>:/tmp/backup.json ./backup.json
```

## 🔄 Container Restart/Rebuild

```bash
# Restart service (Dokploy apps)
# Use Dokploy UI: Redeploy button

# Or via Docker
docker service update --force <service-name>

# Remove old containers
docker container prune -f

# Remove old images
docker image prune -a -f

# Check disk space
df -h
docker system df
```

## 🎯 One-Liners for Common Tasks

```bash
# Get latest container ID for an app
docker ps | grep myapp | awk '{print $1}' | head -1

# Follow logs of latest container
docker logs $(docker ps | grep myapp | awk '{print $1}' | head -1) --follow

# Get all environment variables
docker exec $(docker ps -q --filter name=myapp) printenv

# Quick Django shell
docker exec -it $(docker ps -q --filter name=myapp) python manage.py shell

# Check if migrations needed
docker exec $(docker ps -q --filter name=myapp) python manage.py showmigrations | grep "\[ \]"

# Count users
docker exec $(docker ps -q --filter name=myapp) python manage.py shell -c "from django.contrib.auth.models import User; print(User.objects.count())"

# Test database connection
docker exec $(docker ps -q --filter name=myapp) python -c "import django; django.setup(); from django.db import connection; connection.ensure_connection(); print('✅ DB Connected')"
```

## 📊 Performance Monitoring

```bash
# Container resource usage
docker stats --no-stream

# Disk usage
docker system df

# Network connections
docker exec <container-id> netstat -tlnp

# Memory usage in container
docker exec <container-id> free -h

# CPU usage
docker exec <container-id> top -bn1 | head -10
```

## 🆘 Emergency Debugging

```bash
# Container won't start - check why
docker service ps <service-name> --no-trunc

# Get detailed error
docker inspect <container-id> --format='{{.State.Error}}'

# Check last 100 lines of logs
docker logs <container-id> --tail 100

# Access container filesystem (even if crashed)
docker run --rm -it --entrypoint /bin/sh <image-name>

# Check what's listening on ports
sudo netstat -tlnp | grep 8001
sudo lsof -i :8001
```

## 💾 Backup Commands

```bash
# Export Django data
docker exec <container-id> python manage.py dumpdata > backup.json

# Backup database
docker exec <container-id> pg_dump -U user dbname > backup.sql

# Backup static files
docker cp <container-id>:/app/static ./static-backup/

# Create container snapshot
docker commit <container-id> backup-image:$(date +%Y%m%d)
```

## 🔐 Security Checks

```bash
# Check open ports
sudo netstat -tlnp

# Check firewall
sudo ufw status

# Check failed login attempts
sudo journalctl -u ssh | grep Failed

# Check PostgreSQL authentication
sudo cat /etc/postgresql/*/main/pg_hba.conf

# Verify SSL certificates
sudo certbot certificates
```

---

## 🎓 Pro Tips

### Create Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Docker shortcuts
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlogs='docker logs'
alias dexec='docker exec'
alias dstats='docker stats --no-stream'

# Django shortcuts
alias dmigrate='docker exec $(docker ps -q --filter name=) python manage.py migrate'
alias dshell='docker exec -it $(docker ps -q --filter name=) python manage.py shell'
alias dcollectstatic='docker exec $(docker ps -q --filter name=) python manage.py collectstatic --noinput'

# Quick container ID (replace 'myapp' with your app name)
alias dkid='docker ps | grep myapp | awk "{print \$1}" | head -1'

# Then use like: docker logs $(dkid) --follow
```

### Save Common Commands

Create a `debug.sh` script:

```bash
#!/bin/bash
CONTAINER_ID=$(docker ps | grep your-app | awk '{print $1}' | head -1)

echo "Container ID: $CONTAINER_ID"
echo ""
echo "=== Container Status ==="
docker ps | grep $CONTAINER_ID
echo ""
echo "=== Latest Logs ==="
docker logs $CONTAINER_ID --tail 20
echo ""
echo "=== Environment ==="
docker exec $CONTAINER_ID printenv | grep -E "DEBUG|DATABASE|ALLOWED"
```

Make it executable: `chmod +x debug.sh`

Then run: `./debug.sh`

---

**Bookmark this page! These commands will save you hours of debugging time.** 🚀
