# 🔥 Critical Insights from Real Deployment

**Important lessons learned from deploying a production Django app to Dokploy**

## 1. Settings File Location Matters! ⚠️

**Problem:** We spent hours debugging CSRF_TRUSTED_ORIGINS only to discover Django was loading a different settings file!

**Check which settings file Django actually uses:**
```bash
docker exec <container> python -c "import os; import django; os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings'); django.setup(); from django.conf import settings; import sys; print('Settings file:', sys.modules.get('backend.settings').__file__ if 'backend.settings' in sys.modules else 'NOT LOADED')"
```

**Common patterns:**
- `backend/settings.py` - Single file (simple projects)
- `backend/settings/__init__.py` importing from `production.py` - **This is what we had!**
- `backend/settings/base.py` + `production.py` - Split settings

**Always verify:** Make sure you're editing the file that's actually being imported!

## 2. PostgreSQL Network Access for Docker

**Problem:** Docker containers on `dokploy-network` use `172.18.0.0/16`, not just `172.17.0.0/16`!

**Required pg_hba.conf entries:**
```conf
# Docker bridge network
host    all    all    172.17.0.0/16    scram-sha-256

# Dokploy overlay network (CRITICAL!)
host    all    all    172.18.0.0/16    scram-sha-256

# Optional: Docker Swarm networks
host    all    all    10.0.0.0/8       scram-sha-256
```

**Test from container:**
```bash
docker exec <container> python -c "
import psycopg2
conn = psycopg2.connect('postgresql://user:pass@172.17.0.1:5432/dbname')
print('✅ Connected!')
"
```

## 3. Missing Dependencies Will Kill Your Deployment

**We discovered these missing:**
- `readtime` - Used in blog models
- `django-filter` - Used in API views

**Best practice:** Generate requirements.txt from your actual environment:
```bash
pip freeze > requirements.txt
```

**Or check imports in your code:**
```bash
grep -rh "^import\|^from" --include="*.py" backend/ | \
  grep -v "django\|^from \." | \
  sort -u
```

## 4. .dockerignore Can Block Your Dockerfile!

**Problem:** `.dockerignore` had `Dockerfile*` which blocked `Dockerfile` itself!

**Fix:**
```dockerignore
# Wrong - blocks everything
Dockerfile*

# Right - be specific
Dockerfile.debug
Dockerfile.test
```

## 5. Environment Variables in Django Settings

**Use python-decouple for cleaner config:**

```python
from decouple import config

# Good - with defaults
DEBUG = config('DEBUG', default=False, cast=bool)
SECRET_KEY = config('SECRET_KEY', default='insecure-dev-key')

# Good - split comma-separated values
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost').split(',')
CSRF_TRUSTED_ORIGINS = config('CSRF_TRUSTED_ORIGINS', default='').split(',')

# Good - database URL parsing
DATABASES = {
    'default': dj_database_url.parse(
        config('DATABASE_URL', default='sqlite:///db.sqlite3')
    )
}
```

**In Dokploy environment variables:**
```bash
DEBUG=False
SECRET_KEY=your-50-char-secret
ALLOWED_HOSTS=api.yourdomain.com,yourdomain.com
DATABASE_URL=postgresql://user:pass@172.17.0.1:5432/dbname
CSRF_TRUSTED_ORIGINS=https://api.yourdomain.com,https://yourdomain.com
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

## 6. Debugging Django Settings in Container

**Verify settings are loaded correctly:**
```bash
# Check specific setting
docker exec <container> python manage.py shell -c "from django.conf import settings; print('CSRF_TRUSTED_ORIGINS:', settings.CSRF_TRUSTED_ORIGINS)"

# Check all settings differences from defaults
docker exec <container> python manage.py diffsettings

# Check if attribute exists in module
docker exec <container> python -c "import backend.settings; print(hasattr(backend.settings, 'CSRF_TRUSTED_ORIGINS'))"
```

## 7. Django Admin Needs Migrations First!

**Error:** `relation "auth_user" does not exist`

**Fix:**
```bash
# Run migrations
docker exec <container> python manage.py migrate

# Create superuser
docker exec -it <container> python manage.py createsuperuser
```

## 8. CORS vs CSRF - Both Needed!

**CORS** - Allows frontend to make requests:
```python
CORS_ALLOWED_ORIGINS = ['https://yourdomain.com']
CORS_ALLOW_CREDENTIALS = True
```

**CSRF** - Protects against cross-site attacks:
```python
CSRF_TRUSTED_ORIGINS = ['https://api.yourdomain.com', 'https://yourdomain.com']
```

**Both must include your domains!**

## 9. External PostgreSQL Setup

**Create database and user:**
```sql
CREATE DATABASE your_db;
CREATE USER your_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE your_db TO your_user;
```

**In Django, use host 172.17.0.1 (Docker bridge gateway):**
```bash
DATABASE_URL=postgresql://your_user:password@172.17.0.1:5432/your_db
```

**NOT** `localhost` or `127.0.0.1` - those refer to the container itself!

## 10. Traefik Architecture for Dokploy

```
Internet (HTTPS)
    ↓
nginx (443) - SSL termination
    ↓ http://127.0.0.1:8082
Traefik Router (8082)
    ↓ dokploy-network
Django Container (8001)
    ↓ 172.17.0.1:5432
PostgreSQL (external)
```

**Key points:**
- nginx handles SSL certificates
- Traefik routes to containers
- Containers use overlay network IPs
- External services via Docker bridge gateway

## 11. Healthcheck Start Period

**Your container needs time to:**
- Collect static files
- Test database connection
- Start Gunicorn

**Set appropriate start-period:**
```dockerfile
HEALTHCHECK --interval=30s --timeout=30s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8001/api/ || exit 1
```

## 12. Frontend Static Export Configuration

**For Next.js static export with API calls:**

```javascript
// next.config.js
module.exports = {
  output: 'export',
  distDir: 'out',
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'https://api.yourdomain.com',
  },
}
```

**.env.local (development):**
```bash
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Production build automatically uses default from config!**

## 13. Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `0 lines of code` in Dokploy | `.dockerignore` blocking Dockerfile | Use specific file patterns |
| `no pg_hba.conf entry for host "172.18.x.x"` | Missing network range | Add `172.18.0.0/16` to pg_hba.conf |
| `ModuleNotFoundError: readtime` | Missing dependency | Add to requirements.txt |
| `CSRF_TRUSTED_ORIGINS: []` | Editing wrong settings file | Find actual settings file being loaded |
| `relation "auth_user" does not exist` | No migrations run | `docker exec <container> python manage.py migrate` |
| Frontend shows `localhost:8000` errors | Wrong API URL | Update NEXT_PUBLIC_API_URL and rebuild |

## 14. Pre-Flight Checklist

Before deploying:

**Code:**
- [ ] All dependencies in `requirements.txt`
- [ ] `.dockerignore` doesn't block `Dockerfile`
- [ ] Verify which settings file Django loads
- [ ] CSRF_TRUSTED_ORIGINS and CORS_ALLOWED_ORIGINS set
- [ ] Health check endpoint works (`/api/`)

**Database:**
- [ ] PostgreSQL user created
- [ ] Database created
- [ ] pg_hba.conf allows `172.17.0.0/16` and `172.18.0.0/16`
- [ ] DATABASE_URL uses `172.17.0.1` as host

**Dokploy:**
- [ ] All environment variables set
- [ ] Domain configured correctly
- [ ] Container port matches Gunicorn port
- [ ] Traefik routing file has no syntax errors

**After Deploy:**
- [ ] Run migrations
- [ ] Create superuser
- [ ] Test admin login
- [ ] Test API endpoints
- [ ] Check frontend connection

## 15. Useful Debug Commands

```bash
# Find which settings file is loaded
docker exec <container> python -c "import backend.settings; print(backend.settings.__file__)"

# Check environment variables
docker exec <container> printenv | grep -E "DEBUG|DATABASE|CSRF|CORS"

# Test database connection
docker exec <container> python manage.py dbshell

# Check Traefik config
docker logs dokploy-traefik | grep -i error

# Monitor live requests
docker service logs <service-name> --follow

# Check PostgreSQL connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE datname='your_db';"
```

---

**These insights would have saved us hours! Use this as your deployment debugging guide.**
