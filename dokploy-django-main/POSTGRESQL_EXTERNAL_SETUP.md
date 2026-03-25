# 🐘 PostgreSQL External Database Setup for Dokploy

**Complete guide for using external PostgreSQL with Docker/Dokploy containers**

## Why External PostgreSQL?

✅ **Better for production:**
- Data persists even if container is deleted
- Easier backups and maintenance
- Better performance monitoring
- Shared across multiple applications
- More secure (not in Docker network)

## Network Architecture

```
Docker Container (172.18.0.x)
    ↓
Docker Bridge Gateway (172.17.0.1)
    ↓
PostgreSQL on Host (localhost:5432)
```

**Key Insight:** From inside a Docker container, use `172.17.0.1` to reach host services!

## Step-by-Step Setup

### 1. Install PostgreSQL on VPS

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Create Database and User

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database
CREATE DATABASE your_db_name;

# Create user with password
CREATE USER your_db_user WITH PASSWORD 'strong_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE your_db_name TO your_db_user;

# Grant schema privileges (PostgreSQL 15+)
\c your_db_name
GRANT ALL ON SCHEMA public TO your_db_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_db_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_db_user;

# Exit
\q
```

### 3. Configure Network Access (pg_hba.conf)

**Location:** `/etc/postgresql/*/main/pg_hba.conf`

**Critical:** Add BOTH Docker networks!

```conf
# Docker bridge network (172.17.0.0/16)
host    all    all    172.17.0.0/16    scram-sha-256

# Dokploy overlay network (172.18.0.0/16) - REQUIRED!
host    all    all    172.18.0.0/16    scram-sha-256

# Docker Swarm networks (optional)
host    all    all    10.0.0.0/8       scram-sha-256
```

**Alternative (more permissive):**
```conf
# Allow all Docker networks
host    all    all    172.16.0.0/12    scram-sha-256
host    all    all    10.0.0.0/8       scram-sha-256
```

### 4. Configure PostgreSQL to Listen

**File:** `/etc/postgresql/*/main/postgresql.conf`

```conf
# Listen on all interfaces
listen_addresses = '*'

# Or specific
listen_addresses = 'localhost,172.17.0.1'
```

### 5. Restart PostgreSQL

```bash
sudo systemctl restart postgresql

# Verify it's running
sudo systemctl status postgresql
```

### 6. Test Connection from Container

```bash
# From inside container
docker exec <container-id> python -c "
import psycopg2
try:
    conn = psycopg2.connect(
        host='172.17.0.1',
        port=5432,
        database='your_db_name',
        user='your_db_user',
        password='your_password'
    )
    print('✅ PostgreSQL connection successful!')
    conn.close()
except Exception as e:
    print(f'❌ Connection failed: {e}')
"
```

### 7. Django Configuration

**Environment Variable in Dokploy:**
```bash
DATABASE_URL=postgresql://your_db_user:your_password@172.17.0.1:5432/your_db_name
```

**In Django settings (using dj-database-url):**
```python
import dj_database_url
from decouple import config

DATABASES = {
    'default': dj_database_url.parse(
        config('DATABASE_URL', default='sqlite:///db.sqlite3')
    )
}
```

## Troubleshooting

### Error: "no pg_hba.conf entry for host"

**Full error:**
```
FATAL: no pg_hba.conf entry for host "172.18.0.9", user "your_user", database "your_db"
```

**Solution:**
1. Check which IP the container is using:
   ```bash
   docker exec <container> hostname -i
   ```

2. Add that network range to pg_hba.conf

3. Restart PostgreSQL:
   ```bash
   sudo systemctl restart postgresql
   ```

### Error: "Connection refused"

**Causes:**
- PostgreSQL not listening on the right interface
- Firewall blocking port 5432
- PostgreSQL not running

**Check:**
```bash
# Is PostgreSQL running?
sudo systemctl status postgresql

# Is it listening?
sudo netstat -tlnp | grep 5432

# Check firewall (if ufw is enabled)
sudo ufw status
```

### Error: "password authentication failed"

**Solution:**
1. Verify user exists:
   ```bash
   sudo -u postgres psql -c "\du your_db_user"
   ```

2. Reset password:
   ```bash
   sudo -u postgres psql
   ALTER USER your_db_user WITH PASSWORD 'new_password';
   \q
   ```

3. Update DATABASE_URL in Dokploy

### Wrong Host IP

**Common mistakes:**

❌ `DATABASE_URL=postgresql://user:pass@localhost:5432/db`
- `localhost` refers to the container itself!

❌ `DATABASE_URL=postgresql://user:pass@127.0.0.1:5432/db`
- `127.0.0.1` also refers to the container!

✅ `DATABASE_URL=postgresql://user:pass@172.17.0.1:5432/db`
- Docker bridge gateway - reaches the host!

## Multiple Databases Strategy

### Option 1: One User Per Database
```sql
CREATE DATABASE app1_db;
CREATE USER app1_user WITH PASSWORD 'pass1';
GRANT ALL PRIVILEGES ON DATABASE app1_db TO app1_user;

CREATE DATABASE app2_db;
CREATE USER app2_user WITH PASSWORD 'pass2';
GRANT ALL PRIVILEGES ON DATABASE app2_db TO app2_user;
```

**pg_hba.conf:**
```conf
host    app1_db    app1_user    172.17.0.0/16    scram-sha-256
host    app1_db    app1_user    172.18.0.0/16    scram-sha-256
host    app2_db    app2_user    172.17.0.0/16    scram-sha-256
host    app2_db    app2_user    172.18.0.0/16    scram-sha-256
```

### Option 2: Wildcard (Simpler)
```conf
host    all    all    172.17.0.0/16    scram-sha-256
host    all    all    172.18.0.0/16    scram-sha-256
```

Security is maintained through individual user credentials.

## Security Best Practices

1. **Strong passwords:**
   ```bash
   # Generate secure password
   openssl rand -base64 32
   ```

2. **Limited user privileges:**
   ```sql
   # Don't use superuser for applications
   GRANT CONNECT ON DATABASE your_db TO your_user;
   GRANT USAGE ON SCHEMA public TO your_user;
   GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO your_user;
   ```

3. **Regular backups:**
   ```bash
   # Backup
   sudo -u postgres pg_dump your_db > backup_$(date +%Y%m%d).sql

   # Restore
   sudo -u postgres psql your_db < backup_20251006.sql
   ```

4. **Monitor connections:**
   ```sql
   -- See active connections
   SELECT * FROM pg_stat_activity WHERE datname = 'your_db';
   ```

## Changing Database Password

```bash
# 1. Connect to PostgreSQL
sudo -u postgres psql

# 2. Change password
ALTER USER your_db_user WITH PASSWORD 'new_secure_password';

# 3. Verify
\du your_db_user

# 4. Exit
\q

# 5. Update DATABASE_URL in Dokploy
# DATABASE_URL=postgresql://your_db_user:new_secure_password@172.17.0.1:5432/your_db

# 6. Redeploy container to use new password
```

## Performance Tips

1. **Connection pooling in Django:**
   ```python
   DATABASES = {
       'default': {
           # ... connection details ...
           'CONN_MAX_AGE': 600,  # Keep connections for 10 minutes
       }
   }
   ```

2. **PostgreSQL tuning:**
   ```conf
   # postgresql.conf
   shared_buffers = 256MB
   effective_cache_size = 1GB
   maintenance_work_mem = 64MB
   max_connections = 100
   ```

3. **Indexes on Django models:**
   ```python
   class BlogPost(models.Model):
       slug = models.SlugField(unique=True, db_index=True)
       created_at = models.DateTimeField(auto_now_add=True, db_index=True)
   ```

## Monitoring

```bash
# Check database size
sudo -u postgres psql -c "SELECT pg_size_pretty(pg_database_size('your_db'));"

# Check table sizes
sudo -u postgres psql your_db -c "
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
"

# Active queries
sudo -u postgres psql -c "SELECT pid, usename, application_name, client_addr, query FROM pg_stat_activity WHERE state = 'active';"
```

---

**This setup gives you a production-ready PostgreSQL configuration for Dokploy deployments!**
