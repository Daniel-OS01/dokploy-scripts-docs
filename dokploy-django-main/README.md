# Django Dokploy Template

![Django](https://img.shields.io/badge/Django-5.2.7-green.svg)
![Python](https://img.shields.io/badge/Python-3.13-blue.svg)
![Dokploy](https://img.shields.io/badge/Dokploy-0.25.4-orange.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

**Production-ready Django template for Dokploy deployment with nginx + Traefik routing**

A complete, tested Django 5.2 template configured for seamless deployment on Dokploy with PostgreSQL, Traefik routing, and nginx SSL termination. **Battle-tested in production** with comprehensive debugging guides and real-world insights.

## ✨ Features

- ✅ Django 5.2.7 with PostgreSQL support
- ✅ Docker & Gunicorn production setup
- ✅ Traefik routing integration
- ✅ nginx reverse proxy configuration
- ✅ Health check endpoints
- ✅ CORS headers configured
- ✅ Environment-based configuration
- ✅ Production-ready Dockerfile
- ✅ Complete deployment documentation
- ✅ **Real production insights from actual deployment**
- ✅ **External PostgreSQL setup guide**

## 🚀 Quick Start

### For Deployment (Dokploy)

**👉 Start here:** [`starter-package/docs/QUICK_START.md`](starter-package/docs/QUICK_START.md)

The `starter-package/` directory contains everything you need:
- Configuration templates
- Setup scripts
- Complete documentation
- Step-by-step guides

### For Local Development

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run migrations:**
   ```bash
   python manage.py migrate
   ```

3. **Start development server:**
   ```bash
   python manage.py runserver 8001
   ```

4. **Test endpoints:**
   ```bash
   curl http://localhost:8001/api/health/
   ```

### Docker Development

```bash
docker-compose up
```

Application available at `http://localhost:8001`

## 📦 Starter Package

The [`starter-package/`](starter-package/) directory contains:

```
starter-package/
├── templates/              # Configuration templates
│   ├── .env.production.template
│   ├── nginx-template.conf
│   └── docker-compose.production.yml
├── scripts/               # Setup scripts
│   └── traefik-setup.sh
├── docs/                  # Complete documentation
│   ├── QUICK_START.md
│   ├── DEPLOYMENT_SUCCESS.md
│   └── TEMPLATES_README.md
└── README.md             # Starter package overview
```

**See [`starter-package/README.md`](starter-package/README.md) for complete guide.**

## 🔥 New: Production Insights

**Must-read guides based on real deployment experience:**

- **[CRITICAL_INSIGHTS.md](CRITICAL_INSIGHTS.md)** - 15 critical lessons learned from production deployment
  - Settings file location pitfalls
  - PostgreSQL network configuration
  - Missing dependencies debugging
  - Environment variable best practices
  - And much more!

- **[POSTGRESQL_EXTERNAL_SETUP.md](POSTGRESQL_EXTERNAL_SETUP.md)** - Complete PostgreSQL setup guide
  - Network architecture for Docker
  - pg_hba.conf configuration
  - Multiple database strategies
  - Security best practices
  - Troubleshooting common errors

- **[DEBUG_COMMANDS.md](DEBUG_COMMANDS.md)** - Essential debugging command reference
  - Docker container commands (logs, exec, inspect)
  - Django-specific commands (shell, migrations, users)
  - PostgreSQL debugging (connection, queries)
  - Traefik and nginx troubleshooting
  - One-liners for common tasks
  - Pro tips and aliases

## 📋 Project Structure

```
.
├── myproject/             # Main Django project
│   ├── settings.py        # Django settings (env-based config)
│   ├── urls.py           # URL routing
│   └── wsgi.py           # WSGI application
├── health/               # Health check app
│   ├── views.py          # Health endpoints
│   └── urls.py           # Health URLs
├── starter-package/      # 🎁 Deployment templates & docs
├── Dockerfile            # Production Docker image
├── docker-compose.yml    # Local development
├── requirements.txt      # Python dependencies
└── README.md            # This file
```

## 🔧 Environment Variables

**Core Settings:**
- `DEBUG` - `False` in production
- `SECRET_KEY` - 50+ character secret key
- `ALLOWED_HOSTS` - Your domain(s)
- `DATABASE_URL` - PostgreSQL connection string
- `CORS_ALLOWED_ORIGINS` - Allowed CORS origins

**See [`starter-package/templates/.env.production.template`](starter-package/templates/.env.production.template) for complete list.**

## 🏥 Health Endpoints

- `GET /api/health/` - Health status check
  ```json
  {"status": "healthy", "service": "Django API", "version": "1.0.0"}
  ```

- `GET /api/info/` - Application information
  ```json
  {"name": "Dokploy Django Template", "version": "1.0.0", "framework": "Django 5.2.7"}
  ```

## 🚀 Deployment

### Prerequisites
- VPS with Dokploy installed
- PostgreSQL database
- Domain pointing to your VPS

### Quick Deploy

1. **Setup Traefik** (one time):
   ```bash
   cd starter-package/scripts
   ./traefik-setup.sh
   ```

2. **Follow the guide:**
   Read [`starter-package/docs/QUICK_START.md`](starter-package/docs/QUICK_START.md)

3. **Deploy in Dokploy:**
   - Create Docker Application
   - Set environment variables
   - Configure domain
   - Deploy!

### Full Documentation

- **Quick Start Guide:** [`starter-package/docs/QUICK_START.md`](starter-package/docs/QUICK_START.md)
- **Complete Reference:** [`starter-package/docs/DEPLOYMENT_SUCCESS.md`](starter-package/docs/DEPLOYMENT_SUCCESS.md)
- **Templates Guide:** [`starter-package/docs/TEMPLATES_README.md`](starter-package/docs/TEMPLATES_README.md)
- **Legacy Troubleshooting:** [`DOKPLOY_READY.md`](DOKPLOY_READY.md)

## 🏗️ Architecture

```
Internet (HTTPS)
    ↓
nginx (SSL Termination)
    ↓ Port 8082
Traefik (Dynamic Routing)
    ↓ dokploy-network
Django Container (Gunicorn)
    ↓
PostgreSQL Database
```

**Why this setup?**
- Scalable multi-app architecture
- Automatic routing by domain
- Easy SSL management
- Production-tested

## ✅ Tested & Working

**Successfully deployed and tested in production**

**Environment:**
- Dokploy v0.25.4
- Traefik v3.5.0
- Django 5.2.7
- Python 3.13
- PostgreSQL 16
- Ubuntu VPS

## 🎓 Learn More

- **Dokploy:** https://docs.dokploy.com
- **Django:** https://docs.djangoproject.com
- **Traefik:** https://doc.traefik.io

## 🤝 Contributing

Contributions are welcome! If you find bugs or have improvements:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

## ⭐ Support

If this template helped you deploy your Django app, please:
- ⭐ Star this repository
- 📢 Share with others
- 🐛 Report issues you encounter
- 💡 Suggest improvements

## 📚 Related Resources

- **Dokploy Documentation:** https://docs.dokploy.com
- **Django Documentation:** https://docs.djangoproject.com
- **Traefik Documentation:** https://doc.traefik.io

---

**Ready to deploy?** Start with [`starter-package/README.md`](starter-package/README.md)! 🚀

**Want to publish your own starter kit?** See [PUBLISHING.md](PUBLISHING.md) for guidance.
