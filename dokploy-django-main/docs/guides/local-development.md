# 🏁 Local Development Setup

## Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/your-username/dokploy-django.git
cd dokploy-django
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux
pip install -r requirements.txt
```

### 2. Environment Configuration
```bash
cp .env.example .env
# Edit .env with your local settings
```

### 3. Database Setup
```bash
# Option A: Use SQLite (default)
python manage.py migrate

# Option B: Use PostgreSQL with Docker
docker-compose up -d db
python manage.py migrate
```

### 4. Run Development Server
```bash
python manage.py runserver
```

**Access your app:**
- Main app: http://127.0.0.1:8000/
- Health check: http://127.0.0.1:8000/api/health/
- Admin: http://127.0.0.1:8000/admin/

## Docker Development

### Full Stack with Docker Compose
```bash
# Start all services
docker-compose up

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f web

# Stop services
docker-compose down
```

### Docker Commands
```bash
# Build image
docker build -t dokploy-django .

# Run container
docker run -p 8000:8000 dokploy-django

# Run with environment file
docker run -p 8000:8000 --env-file .env dokploy-django
```

## Development Workflow

### 1. Making Changes
```bash
# Install new packages
pip install package-name
pip freeze > requirements.txt

# Create new Django app
python manage.py startapp your_app_name

# Run migrations after model changes
python manage.py makemigrations
python manage.py migrate
```

### 2. Testing
```bash
# Run tests
python manage.py test

# Check Django configuration
python manage.py check

# Collect static files
python manage.py collectstatic
```

### 3. Prepare for Deployment
```bash
# Update requirements
pip freeze > requirements.txt

# Test Docker build
docker build -t test-build .

# Test production settings
DEBUG=False python manage.py check --deploy
```

## Useful Commands

### Django Management
```bash
# Create superuser
python manage.py createsuperuser

# Django shell
python manage.py shell

# Show migrations
python manage.py showmigrations

# Database shell
python manage.py dbshell
```

### Docker Compose
```bash
# Rebuild services
docker-compose up --build

# Execute commands in container
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser

# View database
docker-compose exec db psql -U postgres -d django_db
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Find process using port 8000
   lsof -ti:8000
   # Kill process
   kill -9 $(lsof -ti:8000)
   ```

2. **Database connection errors**
   ```bash
   # Check PostgreSQL is running
   docker-compose ps
   # Restart database
   docker-compose restart db
   ```

3. **Module not found errors**
   ```bash
   # Reinstall requirements
   pip install -r requirements.txt
   ```

4. **Permission errors**
   ```bash
   # Fix file permissions
   chmod +x manage.py
   ```

### Debug Tips

1. **Enable Django debug toolbar**
   ```bash
   pip install django-debug-toolbar
   # Add to INSTALLED_APPS when DEBUG=True
   ```

2. **Check logs**
   ```bash
   # Django logs (if configured)
   tail -f logs/django.log
   
   # Docker logs
   docker-compose logs -f web
   ```

3. **Database inspection**
   ```bash
   # Django shell
   python manage.py shell
   >>> from django.db import connection
   >>> connection.queries[-10:]  # Last 10 queries
   ```

## IDE Configuration

### VS Code Settings
Create `.vscode/settings.json`:
```json
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black"
}
```

### PyCharm
1. Open project in PyCharm
2. Configure Python interpreter to use `./venv/bin/python`
3. Mark `myproject` as sources root
4. Configure Django settings module: `myproject.settings`
