# 📁 Template Files Overview

This directory contains production-ready templates for deploying Django applications to Dokploy.

## 📋 Template Files

### Configuration Templates

#### `.env.production.template`
**Purpose:** Complete environment variables template for production
**Usage:**
- Copy variables to Dokploy UI → Environment Variables
- Replace all placeholder values
- Generate SECRET_KEY with provided command

**Includes:**
- Django core settings (DEBUG, SECRET_KEY, ALLOWED_HOSTS)
- Database configuration (PostgreSQL)
- CORS settings
- Optional: S3, Email, Redis, Sentry, Stripe, OAuth
- Security settings

#### `nginx-template.conf`
**Purpose:** nginx reverse proxy configuration
**Usage:**
```bash
# Copy to sites-available
cp nginx-template.conf /etc/nginx/sites-available/yourdomain.com

# Replace yourdomain.com with actual domain
sed -i 's/yourdomain.com/actual-domain.com/g' /etc/nginx/sites-available/actual-domain.com

# Get SSL certificate
certbot --nginx -d actual-domain.com

# Enable site
ln -s /etc/nginx/sites-available/actual-domain.com /etc/nginx/sites-enabled/

# Test and reload
nginx -t && systemctl reload nginx
```

**Features:**
- Proxies to Traefik on port 8082
- WebSocket support
- SSL/TLS configuration
- HTTP to HTTPS redirect
- Optional www redirect
- Rate limiting example

#### `docker-compose.production.yml`
**Purpose:** Reference for local production-like testing
**Usage:**
```bash
# Create .env file from template
cp .env.production.template .env
# Edit .env with your values

# Run
docker-compose -f docker-compose.production.yml up -d
```

**Note:** Dokploy doesn't use this - it's for local testing only

### Setup Scripts

#### `traefik-setup.sh`
**Purpose:** One-time Traefik container setup for Dokploy
**Usage:**
```bash
# On your VPS (after Dokploy installation)
chmod +x traefik-setup.sh
sudo ./traefik-setup.sh
```

**What it does:**
- Checks prerequisites (Docker, Dokploy network)
- Removes old Traefik if exists
- Pulls Traefik v3.5.0
- Creates container on ports 8082/8445
- Connects to dokploy-network
- Verifies successful startup

**Run this:** Once per VPS, before deploying any apps

### Documentation

#### `DEPLOYMENT_SUCCESS.md`
**Purpose:** Complete working configuration documentation
**Contains:**
- Full architecture explanation
- All configuration steps
- Critical fixes applied
- Debugging commands
- Adding new applications guide

#### `QUICK_START.md`
**Purpose:** Step-by-step guide for deploying new apps
**Covers:**
- Preparing Django project
- Dokploy configuration
- nginx setup
- Running migrations
- Customization checklist
- Troubleshooting

#### `DOKPLOY_READY.md`
**Purpose:** Original troubleshooting and configuration guide
**Use for:** Reference on common issues and solutions

## 🚀 Quick Deployment Workflow

### First Time Setup (Per VPS)

1. **Install Dokploy** on your VPS
   ```bash
   curl -sSL https://dokploy.com/install.sh | sh
   ```

2. **Setup Traefik**
   ```bash
   ./traefik-setup.sh
   ```

3. **Verify Traefik**
   ```bash
   docker ps | grep traefik
   ```

### For Each New Application

1. **Prepare your Django app**
   - Use this template as base
   - Add your code
   - Push to GitHub

2. **Create app in Dokploy**
   - Use Docker Application type
   - Configure repository
   - Set environment variables from `.env.production.template`
   - Configure domain

3. **Setup nginx**
   - Use `nginx-template.conf`
   - Replace domain name
   - Get SSL certificate
   - Enable and reload

4. **Deploy and test**
   ```bash
   curl https://yourdomain.com/api/health/
   ```

## 📊 File Purpose Summary

| File | When to Use | Required? |
|------|-------------|-----------|
| `.env.production.template` | Every new app (copy to Dokploy UI) | ✅ Yes |
| `nginx-template.conf` | Every new domain | ✅ Yes |
| `traefik-setup.sh` | Once per VPS | ✅ Yes |
| `docker-compose.production.yml` | Local testing only | ❌ Optional |
| `DEPLOYMENT_SUCCESS.md` | Reference/debugging | 📖 Reference |
| `QUICK_START.md` | First deployment | 📖 Guide |
| `DOKPLOY_READY.md` | Troubleshooting | 📖 Reference |

## 🎯 Common Use Cases

### Scenario 1: Brand New VPS + First App

```bash
# 1. Install Dokploy
curl -sSL https://dokploy.com/install.sh | sh

# 2. Setup Traefik
./traefik-setup.sh

# 3. Follow QUICK_START.md for your first app
```

### Scenario 2: Adding Second App to Existing VPS

```bash
# 1. Create app in Dokploy UI
# 2. Copy nginx-template.conf for new domain
# 3. Set up SSL with certbot
# 4. Deploy
```

### Scenario 3: Migrating Existing Django App

```bash
# 1. Update your app's Dockerfile to match this template
# 2. Ensure .dockerignore doesn't block Dockerfile
# 3. Update settings.py to read environment variables
# 4. Push to GitHub
# 5. Deploy in Dokploy
```

### Scenario 4: Local Production Testing

```bash
# 1. Copy .env.production.template to .env
# 2. Fill in values
# 3. Run: docker-compose -f docker-compose.production.yml up -d
# 4. Test: curl http://localhost:8001/api/health/
```

## ⚙️ Customization Guide

### Adding Custom Environment Variables

1. **Add to `.env.production.template`**
   ```bash
   # Custom settings
   MY_CUSTOM_API_KEY=your-key-here
   FEATURE_FLAG_X=True
   ```

2. **Add to Dokploy UI** when deploying

3. **Use in Django settings.py**
   ```python
   MY_CUSTOM_API_KEY = os.environ.get('MY_CUSTOM_API_KEY')
   FEATURE_FLAG_X = os.environ.get('FEATURE_FLAG_X', 'False').lower() == 'true'
   ```

### Changing Traefik Ports

If ports 8082/8445 are in use:

1. **Edit `traefik-setup.sh`**
   ```bash
   # Change -p lines:
   -p 8090:80/tcp \
   -p 8450:443/tcp \
   -p 8450:443/udp \
   ```

2. **Edit `nginx-template.conf`**
   ```nginx
   proxy_pass http://127.0.0.1:8090;
   ```

3. **Recreate Traefik**
   ```bash
   ./traefik-setup.sh
   ```

### Adding Middleware to Traefik

Create `/etc/dokploy/traefik/dynamic/middlewares.yml`:
```yaml
http:
  middlewares:
    rate-limit:
      rateLimit:
        average: 100
        burst: 50
```

Reference in your app's Traefik config in Dokploy UI.

## 🔍 Troubleshooting

### Templates Not Working?

**Check:**
- [ ] All placeholder values replaced (yourdomain.com, passwords, etc.)
- [ ] SECRET_KEY is 50+ characters
- [ ] DATABASE_URL format is correct
- [ ] Domain DNS points to your VPS
- [ ] Traefik is running: `docker ps | grep traefik`
- [ ] nginx config has no syntax errors: `nginx -t`

### Environment Variables Not Loading?

**In Dokploy:**
- Use `ALLOWED_HOSTS` not `DJANGO_ALLOWED_HOSTS`
- Check capitalization (case-sensitive)
- No quotes around values in Dokploy UI
- Click "Save" then "Redeploy"

### SSL Certificate Issues?

```bash
# Renew certificates
certbot renew

# Force renewal
certbot renew --force-renewal

# Check expiry
certbot certificates
```

## 📚 Additional Resources

- **Dokploy Docs:** https://docs.dokploy.com
- **Django Docs:** https://docs.djangoproject.com
- **Traefik Docs:** https://doc.traefik.io/traefik/
- **nginx Docs:** https://nginx.org/en/docs/

## 🎉 Success Checklist

After using these templates, you should have:

- [x] Django app running in Docker
- [x] Traefik routing by domain
- [x] nginx handling SSL
- [x] External PostgreSQL connected
- [x] Health endpoint responding
- [x] Scalable architecture ready
- [x] Easy to add more apps

**All templates tested and working as of October 2025!** ✅
