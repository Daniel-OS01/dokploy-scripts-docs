# 🔧 Environment Variables Guide

## Required Variables

### Django Core Settings

```bash
# Django secret key - Generate a strong 50+ character key
SECRET_KEY=your-super-secret-key-minimum-50-characters-long-here

# Debug mode - Always False in production
DEBUG=False

# Allowed hosts - Include your domain and localhost
ALLOWED_HOSTS=your-domain.com,localhost,127.0.0.1
```

### Database Configuration

```bash
# PostgreSQL connection string
DATABASE_URL=postgresql://username:password@host:5432/database_name
```

**Format Breakdown:**
- `username`: PostgreSQL user
- `password`: User password
- `host`: Database server host (IP or domain)
- `5432`: PostgreSQL port (default)
- `database_name`: Target database

### CORS Configuration

```bash
# Frontend domains allowed to make requests
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com,https://www.your-domain.com
```

## Environment-Specific Configurations

### Development
```bash
DEBUG=True
SECRET_KEY=django-insecure-development-key-not-for-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/django_dev
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

### Production
```bash
DEBUG=False
SECRET_KEY=your-production-secret-key-50-characters-minimum
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
DATABASE_URL=postgresql://prod_user:secure_password@db.yourdomain.com:5432/prod_db
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

## Security Best Practices

1. **SECRET_KEY**
   - Minimum 50 characters
   - Use random characters, numbers, symbols
   - Never reuse across environments
   - Generate new key: `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`

2. **Database Passwords**
   - Use strong, unique passwords
   - Avoid common passwords
   - Consider using database password rotation

3. **ALLOWED_HOSTS**
   - Only include necessary domains
   - Don't use wildcards in production
   - Include both www and non-www versions

4. **CORS Origins**
   - Only include trusted frontend domains
   - Use HTTPS in production
   - Avoid wildcard origins (`*`)

## Dokploy-Specific Notes

### Variable Format
- In Dokploy UI, enter variables without quotes
- Multi-line variables should be wrapped in double quotes
- Environment variables are injected at container runtime

### Validation
After setting variables in Dokploy:
1. Deploy the application
2. Check logs for any environment variable errors
3. Test endpoints to verify configuration
4. Monitor application health

### Common Mistakes
- ❌ Including quotes around values in Dokploy UI
- ❌ Using spaces around `=` in variable names
- ❌ Setting DEBUG=True in production
- ❌ Using weak SECRET_KEY values
- ❌ Forgetting to include domain in ALLOWED_HOSTS
