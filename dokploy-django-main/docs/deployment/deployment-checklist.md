# ✅ Dokploy Deployment Checklist

## Pre-Deployment Verification

### Local Testing ✅
- [x] Django server runs locally (`python manage.py runserver`)
- [x] Health endpoint works (`/api/health/`)
- [x] Info endpoint works (`/api/info/`)  
- [x] Database migrations successful
- [x] Docker build completes
- [x] Docker container runs properly

### Repository Setup ✅
- [x] Git repository initialized
- [x] All files committed
- [x] `.gitignore` configured properly
- [x] Virtual environment excluded
- [x] Sensitive files excluded

## Dokploy Deployment Steps

### Step 1: Repository Publishing
- [ ] Push repository to GitHub
- [ ] Verify repository is accessible
- [ ] Check branch is `main`
- [ ] Confirm all files are present

### Step 2: Dokploy Application Creation
- [ ] Login to Dokploy dashboard
- [ ] Click "Create Application"
- [ ] Choose **"Docker Application"** (not Docker Compose)
- [ ] Set application name: `django-template-test`

### Step 3: Repository Configuration
- [ ] Source Type: **Git**
- [ ] Repository URL: `https://github.com/your-username/repo-name.git`
- [ ] Branch: **main**
- [ ] Build Path: **/** (root directory)
- [ ] Dockerfile Path: **Dockerfile**

### Step 4: Environment Variables
Set these in Dokploy Environment tab:

```bash
DEBUG=False
SECRET_KEY=django-insecure-test-key-for-deployment-change-in-production-123456789012345678901234567890
ALLOWED_HOSTS=your-domain.com,localhost,127.0.0.1
DATABASE_URL=postgresql://username:password@host:5432/database
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com
```

**Variables Checklist:**
- [ ] `DEBUG` set to `False`
- [ ] `SECRET_KEY` is 50+ characters
- [ ] `ALLOWED_HOSTS` includes your domain
- [ ] `DATABASE_URL` format is correct
- [ ] `CORS_ALLOWED_ORIGINS` includes frontend domain

### Step 5: Deploy
- [ ] Click **Deploy** button
- [ ] Monitor build logs
- [ ] Wait for "Running" status
- [ ] Check for build errors

### Step 6: Domain Configuration
- [ ] Go to Domains tab
- [ ] Add domain: `your-domain.com`
- [ ] Set port: **8000**
- [ ] Set path: **/**
- [ ] Enable SSL: **Yes**

## Post-Deployment Verification

### Health Checks
Test these endpoints after deployment:

- [ ] `https://your-domain.com/api/health/`
  ```json
  {
    "status": "healthy",
    "service": "Django API", 
    "version": "1.0.0",
    "message": "Service is running normally"
  }
  ```

- [ ] `https://your-domain.com/api/info/`
  ```json
  {
    "name": "Dokploy Django Template",
    "description": "Minimal Django template for Dokploy deployment",
    "version": "1.0.0", 
    "framework": "Django 5.2.7"
  }
  ```

- [ ] `https://your-domain.com/admin/`
  - Should show Django admin login

### Monitoring
- [ ] Check application status in Dokploy (should be "Running")
- [ ] Monitor CPU and memory usage
- [ ] Check application logs for errors
- [ ] Verify SSL certificate is working

## Troubleshooting

### If "Zero Lines of Code" Error
- [ ] Verify repository URL is correct
- [ ] Check repository is public or SSH keys configured
- [ ] Try disconnecting and reconnecting repository
- [ ] Ensure branch name is exactly `main`
- [ ] Check build path is `/` (root)

### If Build Fails
- [ ] Check Dockerfile syntax
- [ ] Verify requirements.txt is complete
- [ ] Check for missing dependencies in logs
- [ ] Test Docker build locally first

### If 502 Bad Gateway
- [ ] Check container logs in Dokploy
- [ ] Verify environment variables are set correctly
- [ ] Check if container is actually running
- [ ] Verify port 8000 is exposed properly
- [ ] Test health endpoint directly

### If Database Errors
- [ ] Check DATABASE_URL format
- [ ] Verify database server is accessible
- [ ] Test database connection from Dokploy server
- [ ] Check database credentials
- [ ] Run migrations if needed

## Next Steps After Success

### If Template Deploys Successfully ✅
1. **Celebrate!** 🎉 Your Dokploy setup is working
2. **Document your success** - note working configuration
3. **Add your real Django apps** to this template
4. **Configure production database** properly
5. **Set up monitoring and backups**

### If Template Fails ❌
1. **Check logs** in Dokploy deployment tab
2. **Verify each step** in this checklist
3. **Test locally** to isolate issues
4. **Compare with working configuration**
5. **Ask for help** with specific error messages

---

## Success Criteria

**✅ Template is working when:**
- Dokploy shows "Running" status
- Health endpoint returns JSON
- No 502 errors on domain
- Container stays running
- Build logs show no errors

**This means your Dokploy setup is correct and you can deploy real applications!**
