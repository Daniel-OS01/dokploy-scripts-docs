# 🚀 Quick Start Guide - Deploy New Django App to Dokploy

This guide shows how to deploy a **new Django application** using this template.

## 📋 Prerequisites

- ✅ Dokploy installed on your VPS
- ✅ Traefik container running (see DEPLOYMENT_SUCCESS.md)
- ✅ PostgreSQL database available
- ✅ Domain name pointing to your VPS
- ✅ nginx installed on VPS

## 🎯 Step-by-Step Deployment

### Step 1: Prepare Your Django Project

```bash
# Clone this template or use it as a base
git clone https://github.com/pkieber/dokploy-django.git my-new-app
cd my-new-app

# Update your Django app code in myproject/ and health/ directories
# Add your models, views, etc.
```

### Step 2: Update Configuration Files

**Update `.dockerignore`** (already configured)
- ✅ Excludes `Dockerfile.debug` (not `Dockerfile*`)
- ✅ Keeps your Dockerfile available

**Update `requirements.txt`**
```txt
# Add your dependencies
Django==5.2.7
gunicorn==23.0.0
psycopg2-binary==2.9.10
python-dotenv==1.1.1
dj-database-url==3.0.1
django-cors-headers==4.9.0

# Add your packages below
djangorestframework==3.14.0
celery==5.3.4
# etc...
```

**Update `myproject/settings.py`**
- Configure your INSTALLED_APPS
- Add middleware
- Configure CORS settings
- Set up static files

### Step 3: Push to GitHub

```bash
# Create a new repository on GitHub
git remote set-url origin https://github.com/yourusername/your-new-app.git
git add .
git commit -m "Initial commit - Django app for Dokploy"
git push -u origin main
```

### Step 4: Create Application in Dokploy

1. **Go to Dokploy Dashboard** (https://your-vps:3000)

2. **Create New Application**
   - Click "Create Application"
   - Type: **Docker Application** (not Docker Compose)
   - Name: `my-new-app`

3. **Configure Repository**
   - Provider: GitHub
   - Repository URL: `https://github.com/yourusername/your-new-app.git`
   - Branch: `main`
   - Build Type: **Dockerfile**
   - Build Path: `/` (or leave empty)
   - Dockerfile: `Dockerfile`

4. **Set Environment Variables**

   Copy from `.env.production.template` and configure:

   ```bash
   DEBUG=False
   SECRET_KEY=generate-a-real-secret-key-here-50-characters-minimum
   ALLOWED_HOSTS=mynewapp.com,www.mynewapp.com
   DATABASE_URL=postgresql://user:pass@host:5432/database
   CORS_ALLOWED_ORIGINS=https://mynewapp.com
   ```

   **Generate SECRET_KEY:**
   ```bash
   python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
   ```

5. **Configure Domain**
   - Go to "Domains" tab
   - Click "Add Domain"
   - Host: `mynewapp.com`
   - Container Port: `8001`
   - Path: `/`
   - Save

6. **Deploy**
   - Click "Deploy" button
   - Wait for build to complete
   - Check logs for any errors

### Step 5: Setup nginx on VPS

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Copy nginx template
cd /etc/nginx/sites-available/
nano mynewapp.com

# Paste the content from nginx-template.conf
# Replace all instances of "yourdomain.com" with "mynewapp.com"
# Save and exit

# Get SSL certificate
certbot --nginx -d mynewapp.com

# Enable the site
ln -s /etc/nginx/sites-available/mynewapp.com /etc/nginx/sites-enabled/

# Test nginx configuration
nginx -t

# Reload nginx
systemctl reload nginx
```

### Step 6: Verify Deployment

```bash
# Test health endpoint
curl https://mynewapp.com/api/health/

# Expected response:
# {"status": "healthy", "service": "Django API", ...}
```

### Step 7: Run Migrations

**Option A: Via Dokploy UI**
1. Go to your app in Dokploy
2. Click "Advanced" → "Run Command"
3. Enter: `python manage.py migrate`
4. Click "Run"

**Option B: Via SSH to VPS**
```bash
# Find your container
docker ps | grep my-new-app

# Run migrations
docker exec <container-id> python manage.py migrate

# Create superuser (interactive)
docker exec -it <container-id> python manage.py createsuperuser
```

## 🎨 Customization Checklist

After deploying, customize your app:

- [ ] Update `health/views.py` with your service info
- [ ] Add your Django apps to `INSTALLED_APPS`
- [ ] Configure middleware (CORS, security, etc.)
- [ ] Set up static files serving
- [ ] Configure media files (if needed)
- [ ] Add custom models and migrations
- [ ] Set up Celery (if needed)
- [ ] Configure logging
- [ ] Add monitoring (Sentry, etc.)

## 🔧 Common Post-Deployment Tasks

### Add a New Django App

```bash
# Locally
python manage.py startapp myapp

# Add to settings.py INSTALLED_APPS
INSTALLED_APPS = [
    ...
    'myapp',
]

# Create models, views, etc.
# Commit and push
git add .
git commit -m "Add myapp"
git push

# In Dokploy, click "Redeploy"
# Then run migrations (see Step 7)
```

### Update Environment Variables

1. Go to Dokploy → Your App → Settings → Environment
2. Edit variables
3. Click "Save"
4. Click "Redeploy" to apply changes

### View Logs

**In Dokploy UI:**
- Go to your app → Logs tab

**Via SSH:**
```bash
# Service logs
docker service logs <service-name> --tail 100

# Container logs
docker logs <container-id> --tail 100
```

### Scale Your Application

```bash
# In Dokploy UI: Advanced → Cluster → Replicas
# Set to 2 or more for high availability

# Or via CLI
docker service scale my-new-app=3
```

## 🚨 Troubleshooting

### Container Won't Start

1. **Check logs** in Dokploy UI
2. **Verify environment variables** are set correctly
3. **Check DATABASE_URL** format and connectivity
4. **Verify ALLOWED_HOSTS** includes your domain

### 502 Bad Gateway

1. **Check if container is running:** `docker ps | grep my-new-app`
2. **Check Traefik logs:** `docker logs dokploy-traefik --tail 50`
3. **Verify domain in Dokploy** matches nginx config
4. **Check for conflicting routes** in Traefik

### Database Connection Errors

```bash
# Test database connectivity from container
docker exec <container-id> python manage.py dbshell

# If fails, check:
# - DATABASE_URL format
# - Database server is running
# - Network connectivity
# - Database credentials
```

## 📚 Additional Resources

- **Main docs:** `DEPLOYMENT_SUCCESS.md` - Full deployment details
- **Environment template:** `.env.production.template` - All env vars
- **nginx template:** `nginx-template.conf` - nginx configuration
- **Dokploy docs:** https://docs.dokploy.com

## 🎉 Success!

Your Django app should now be:
- ✅ Running in Docker
- ✅ Accessible via your domain
- ✅ Proxied through nginx + Traefik
- ✅ Using external PostgreSQL
- ✅ Ready for production!

**Next:** Build your features and scale as needed! 🚀
