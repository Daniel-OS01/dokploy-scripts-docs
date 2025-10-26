# 🚀 Dokploy Deployment Guide

## Overview

This guide covers deploying the Django template to Dokploy following their best practices.

## Prerequisites

1. **Dokploy Server**: Running instance of Dokploy
2. **PostgreSQL Database**: External database configured
3. **Domain**: DNS pointing to your Dokploy server
4. **GitHub Repository**: Code pushed to repository

## Deployment Steps

### Step 1: Create Application in Dokploy

1. **Login** to your Dokploy dashboard
2. **Click "Create Application"**
3. **Choose "Docker Application"** (single container)
4. **Name**: `django-template`

### Step 2: Configure Repository

1. **Source Type**: Git
2. **Repository URL**: `https://github.com/your-username/dokploy-django.git`
3. **Branch**: `main`
4. **Build Path**: `/` (root directory)
5. **Dockerfile Path**: `Dockerfile`

### Step 3: Environment Variables

Set these in Dokploy's Environment section:

```bash
# Django Configuration
DEBUG=False
SECRET_KEY=your-super-secret-key-minimum-50-characters-long-here
ALLOWED_HOSTS=your-domain.com,localhost,127.0.0.1

# Database Configuration (External PostgreSQL)
DATABASE_URL=postgresql://username:password@host:5432/database_name

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com
```

### Step 4: Domain Configuration

1. **Go to Domains tab** in your application
2. **Add Domain**: `your-domain.com`
3. **Port**: `8000` (Django runs on port 8000)
4. **Path**: `/`
5. **Enable SSL**: Yes (Let's Encrypt)

### Step 5: Deploy

1. **Click Deploy**
2. **Monitor logs** for build progress
3. **Wait for "Running" status**

## Health Checks

After deployment, verify these endpoints:

- **Health Check**: `https://your-domain.com/api/health/`
- **Info**: `https://your-domain.com/api/info/`
- **Admin**: `https://your-domain.com/admin/`

## Expected Responses

### Health Check
```json
{
  "status": "healthy",
  "service": "Django API",
  "version": "1.0.0",
  "message": "Service is running normally"
}
```

### Info
```json
{
  "name": "Dokploy Django Template",
  "description": "Minimal Django template for Dokploy deployment",
  "version": "1.0.0",
  "framework": "Django 5.2.7"
}
```

## Troubleshooting

### Common Issues

1. **502 Bad Gateway**
   - Check container logs in Dokploy
   - Verify environment variables are set
   - Ensure database connection is working

2. **Build Failures**
   - Check Dockerfile syntax
   - Verify requirements.txt is complete
   - Check for missing dependencies

3. **Database Connection Issues**
   - Verify DATABASE_URL format
   - Test database connectivity from Dokploy server
   - Check firewall/security group settings

### Monitoring

Use Dokploy's built-in monitoring to track:
- CPU usage
- Memory usage
- Network traffic
- Application logs

## Security Best Practices

1. **Never commit secrets** to repository
2. **Use strong SECRET_KEY** (50+ characters)
3. **Set DEBUG=False** in production
4. **Configure ALLOWED_HOSTS** properly
5. **Use HTTPS** with SSL certificates
6. **Regular backups** of database

## Next Steps

Once deployed successfully:
1. Set up database migrations
2. Create Django superuser
3. Configure monitoring alerts
4. Set up automated backups
5. Add your custom Django apps
