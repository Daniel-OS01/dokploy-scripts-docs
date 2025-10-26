# ✅ DOKPLOY DEPLOYMENT - WORKING CONFIGURATION

**Status:** Successfully deployed in production
**Last Updated:** October 7, 2025

> ⚠️ **NEW:** See [CRITICAL_INSIGHTS.md](../../../CRITICAL_INSIGHTS.md) for lessons learned from real production deployment!

## 🎯 Working Architecture

```
Internet (443/80)
    ↓
nginx (Host Reverse Proxy)
    ↓ port 8082
Traefik (Dokploy Router)
    ↓ dokploy-network
Django Container (port 8001)
```

## 📋 Complete Configuration

### 1. Dokploy Application Settings

- **Application Type:** Docker Application
- **Repository:** `https://github.com/pkieber/dokploy-django.git`
- **Branch:** `main`
- **Build Path:** `/` (or leave empty)
- **Dockerfile:** `Dockerfile`

### 2. Environment Variables in Dokploy

```bash
DEBUG=False
SECRET_KEY=django-insecure-test-key-for-deployment-change-in-production-123456789012345678901234567890
ALLOWED_HOSTS=api.yourdomain.com,localhost,127.0.0.1
DATABASE_URL=postgresql://user:password@172.17.0.1:5432/database
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

**Important:** Use `ALLOWED_HOSTS` (not `DJANGO_ALLOWED_HOSTS`)

### 3. Dokploy Domain Configuration

- **Host:** `api.yourdomain.com`
- **Container Port:** `8001`
- **Path:** `/`
- **Internal Path:** `/`

### 4. Traefik Container Setup

**Create Traefik container** (runs separately from Dokploy service):

```bash
docker run -d \
    --name dokploy-traefik \
    --restart always \
    -v /etc/dokploy/traefik/traefik.yml:/etc/traefik/traefik.yml \
    -v /etc/dokploy/traefik/dynamic:/etc/dokploy/traefik/dynamic \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8082:80/tcp \
    -p 8445:443/tcp \
    -p 8445:443/udp \
    traefik:v3.5.0

docker network connect dokploy-network dokploy-traefik
```

**Why custom ports (8082/8445)?**
- Port 80/443 already used by host nginx
- Nginx proxies to Traefik on port 8082
- Traefik routes to Docker containers by domain

### 5. nginx Configuration

**File:** `/etc/nginx/sites-available/api.yourdomain.com`

```nginx
server {
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
    if ($host = api.yourdomain.com) {
        return 301 https://$host$request_uri;
    }

    listen 80;
    server_name api.yourdomain.com;
    return 404;
}
```

**Reload nginx:**
```bash
nginx -t && systemctl reload nginx
```

## 🔧 Critical Fixes Applied

### Issue 1: .dockerignore Blocking Dockerfile
**Problem:** `.dockerignore` had `Dockerfile*` which excluded the Dockerfile
**Fix:** Changed to `Dockerfile.debug` (specific file only)

**File:** `.dockerignore` line 3
```diff
- Dockerfile*
+ Dockerfile.debug
```

### Issue 2: Environment Variable Name Mismatch
**Problem:** Dokploy had `DJANGO_ALLOWED_HOSTS` but Django reads `ALLOWED_HOSTS`
**Fix:** Renamed to `ALLOWED_HOSTS` in Dokploy environment variables

### Issue 3: Traefik Not Running
**Problem:** Traefik container was stopped, ports 8080/8443 weren't listening
**Fix:** Deployed new Traefik v3.5.0 container on ports 8082/8445

### Issue 4: Conflicting Traefik Routes
**Problem:** Multiple apps configured for same domain with same priority
**Fix:** Deleted old/stopped applications in Dokploy UI

## ✅ Verification

Test the deployment:

```bash
curl https://api.yourdomain.com/api/health/
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "Django API",
  "version": "1.0.0",
  "message": "Service is running normally"
}
```

## 📊 Adding New Applications

With this setup, adding new Dokploy apps is simple:

1. **Deploy app in Dokploy** with domain configuration
2. **Create nginx config** for the new domain:

```nginx
server {
    server_name newapp.yourdomain.com;

    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/newapp.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/newapp.yourdomain.com/privkey.pem;
}
```

3. **Reload nginx:** `systemctl reload nginx`

Traefik automatically routes based on the `Host` header!

## 🚨 Common Pitfalls to Avoid

1. **Don't use `Dockerfile*` in `.dockerignore`** - Be specific with exclusions
2. **Match environment variable names** - Django reads `ALLOWED_HOSTS`, not `DJANGO_ALLOWED_HOSTS`
3. **Include domain in ALLOWED_HOSTS** - Add your actual domain, not just localhost
4. **Remove old/conflicting apps** - Delete stopped apps that use the same domain
5. **Verify Traefik is running** - Check `docker ps | grep traefik`

## 🔍 Debugging Commands

```bash
# Check Django container status
docker ps | grep django-backend

# Check Traefik status
docker ps | grep traefik

# View Django container logs
docker service logs django-backend-x1zzed --tail 50

# View Traefik logs
docker logs dokploy-traefik --tail 50

# Check Traefik routes
docker exec dokploy-traefik wget -O- http://localhost:8080/api/http/routers 2>/dev/null

# Test from container
docker exec dokploy-traefik wget -O- http://django-backend-x1zzed:8001/api/health/

# Check network connectivity
docker network inspect dokploy-network
```

## 📝 Key Learnings

1. **Dokploy v0.25.4 expects external Traefik container** - Not embedded
2. **Traefik uses file-based dynamic config** - Located in `/etc/dokploy/traefik/dynamic/`
3. **Swarm overlay networks** require proper service naming for DNS
4. **nginx + Traefik combo** works well for multi-site VPS hosting
5. **Dokploy auto-generates Traefik configs** - One YAML file per application

## 🎉 Success!

Your Django app is now:
- ✅ Containerized and running
- ✅ Routed through Traefik
- ✅ Served via nginx with SSL
- ✅ Scalable architecture for multiple apps
- ✅ Production-ready deployment pattern
