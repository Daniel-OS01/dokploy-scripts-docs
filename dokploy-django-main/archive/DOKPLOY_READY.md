# 🚀 DOKPLOY DEPLOYMENT - READY TO TEST

## 📋 Repository Information

**Repository URL:** `https://github.com/pkieber/dokploy-django`  
**Branch:** `main`  
**Status:** ✅ Public and accessible  
**Purpose:** Minimal Django template for Dokploy testing  

## 🎯 **DOKPLOY CONFIGURATION**

### Application Settings
- **Application Type:** `Docker Application` (NOT Docker Compose)
- **Repository URL:** `https://github.com/pkieber/dokploy-django.git`
- **Branch:** `main`
- **Build Path:** `/`
- **Dockerfile Path:** `Dockerfile`

### Required Environment Variables
```bash
DEBUG=False
SECRET_KEY=django-insecure-test-key-for-deployment-change-in-production-123456789012345678901234567890
ALLOWED_HOSTS=your-domain.com,localhost,127.0.0.1
DATABASE_URL=postgresql://username:password@host:5432/database_name
CORS_ALLOWED_ORIGINS=https://your-domain.com
```

**⚠️ Notes:**
- **PostgreSQL Required:** You need an external PostgreSQL database
- Replace `username:password@host:5432/database_name` with your actual database credentials
- Replace `your-domain.com` with actual domain
- Generate proper SECRET_KEY for production

## 💾 **POSTGRESQL CONFIGURATION**

### Option 1: External PostgreSQL Database
If you have an existing PostgreSQL server:
```bash
DATABASE_URL=postgresql://your_user:your_password@your_host:5432/your_database
```

**Example:**
```bash
DATABASE_URL=postgresql://kieber_user:KIE2drei4!@172.17.0.1:5432/kieber_tech
```

### Option 2: Dokploy Managed Database
1. **Create Database in Dokploy:**
   - Go to "Databases" section
   - Click "Create Database"
   - Choose "PostgreSQL"
   - Set database name, user, and password

2. **Use Internal Connection:**
   ```bash
   DATABASE_URL=postgresql://db_user:db_password@dokploy_postgres:5432/db_name
   ```

### Option 3: Docker Compose (Development Only)
For local development, the included `docker-compose.yml` provides PostgreSQL:
```bash
docker-compose up -d db
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/django_db
```

**⚠️ Important:** Replace the placeholder credentials with your actual PostgreSQL database information.

## 🧪 **TEST ENDPOINTS**

After deployment, verify these work:

### Health Check
```bash
curl https://your-domain.com/api/health/
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

### Info Endpoint
```bash
curl https://your-domain.com/api/info/
```
**Expected Response:**
```json
{
  "name": "Dokploy Django Template",
  "description": "Minimal Django template for Dokploy deployment",
  "version": "1.0.0",
  "framework": "Django 5.2.7"
}
```

### Admin Panel
- URL: `https://your-domain.com/admin/`
- Should show Django admin login page

## 🔍 **SUCCESS INDICATORS**

**✅ Deployment Successful When:**
- Repository connects (no "zero lines of code")
- Docker build completes without errors
- Container status shows "Running" 
- Health endpoint returns JSON (not 502)
- Domain resolves to application
- No error messages in logs

## 🛠️ **TROUBLESHOOTING QUICK REFERENCE**

### Issue: "Zero Lines of Code"
**Solution:** 
- Verify repository URL: `https://github.com/pkieber/dokploy-django.git`
- Check branch is `main` 
- Set Build Path to `/`
- Try deleting and recreating application

### Issue: Docker Build Fails
**Solution:**
- Check build logs in Dokploy
- Verify Dockerfile exists in repository root
- Test locally: `docker build -t test .`

### Issue: 502 Bad Gateway
**Solution:**
- Check container logs
- Verify environment variables are set
- Ensure container is running (not restarting)
- Test health endpoint

### Issue: Container Won't Start
**Solution:**
- Check SECRET_KEY is 50+ characters
- Verify ALLOWED_HOSTS includes your domain
- Check for missing environment variables
- Review Django startup logs

### Issue: PostgreSQL Connection Errors
**Symptoms:**
- `django.db.utils.OperationalError`
- `connection refused`
- `could not connect to server`

**Solutions:**
1. **Check DATABASE_URL format:**
   ```bash
   # Correct format
   DATABASE_URL=postgresql://username:password@host:5432/database_name
   
   # Common mistakes to avoid
   DATABASE_URL=postgres://...     # Wrong (should be postgresql://)
   DATABASE_URL=postgresql://...@localhost/db  # Missing port
   ```

2. **Verify Database Server:**
   ```bash
   # Test connection from Dokploy server
   psql "postgresql://username:password@host:5432/database_name"
   ```

3. **Check Network Access:**
   - Ensure PostgreSQL allows connections from Dokploy server
   - Check firewall rules on database server
   - Verify security groups/network policies

4. **Database Permissions:**
   ```sql
   -- Grant necessary permissions
   GRANT ALL PRIVILEGES ON DATABASE your_database TO your_user;
   ```

## 📊 **DEPLOYMENT STEPS SUMMARY**

1. **Create Dokploy Application**
   - Type: Docker Application
   - Name: `django-test`

2. **Configure Repository**
   - URL: `https://github.com/pkieber/dokploy-django.git`
   - Branch: `main`

3. **Set Environment Variables** (copy from above)

4. **Deploy and Monitor**
   - Click Deploy
   - Watch build logs
   - Wait for "Running" status

5. **Configure Domain**
   - Add your domain
   - Port: `8001`
   - Enable SSL

6. **Test Endpoints** (use URLs above)

## 🎉 **NEXT STEPS AFTER SUCCESS**

If this minimal template works:

1. **🎉 Celebrate!** Your Dokploy setup is working perfectly
2. **📝 Document** your successful configuration  
3. **🔧 Extend** this template with your actual Django application
4. **💾 Configure** production PostgreSQL database
5. **🔒 Secure** with proper SECRET_KEY and credentials
6. **📊 Monitor** with Dokploy's built-in tools

---

## 📞 **IMMEDIATE ACTION ITEMS**

1. **Go to your Dokploy dashboard**
2. **Create new Docker Application**  
3. **Use repository:** `https://github.com/pkieber/dokploy-django.git`
4. **Set environment variables** from this document
5. **Deploy and test** health endpoints
6. **Report results** - success or specific error messages

**This template is specifically designed to help diagnose Dokploy issues and establish a working baseline!**
