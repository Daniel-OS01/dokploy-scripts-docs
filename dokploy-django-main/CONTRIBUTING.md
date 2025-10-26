# Contributing to Django Dokploy Template

Thank you for considering contributing to this project! 🎉

This template was born from real production deployment experience, and we welcome contributions that help others deploy Django apps more easily.

## 🎯 Types of Contributions

### 1. Bug Reports
If you encounter issues deploying with this template:

- Check existing [Issues](../../issues) first
- Provide your environment details (Django version, Dokploy version, OS)
- Include error messages and logs
- Describe steps to reproduce

**Template for bug reports:**
```markdown
**Environment:**
- Django version:
- Dokploy version:
- Python version:
- PostgreSQL version:
- OS:

**What I tried:**
1. Step 1
2. Step 2

**Expected behavior:**
...

**Actual behavior:**
...

**Error logs:**
```
...
```
```

### 2. Documentation Improvements
- Fix typos or unclear instructions
- Add missing steps you discovered
- Improve existing guides
- Translate documentation

### 3. New Features
- Additional Django apps (e.g., Redis, Celery setup)
- Alternative database configurations
- CI/CD pipeline examples
- Monitoring/logging integrations
- Performance optimizations

### 4. Production Insights
If you deployed using this template and learned something new:

- Add to `CRITICAL_INSIGHTS.md`
- Update `DEBUG_COMMANDS.md` with helpful commands
- Share your architecture decisions

## 🔧 Development Workflow

### Setting Up for Development

1. **Fork and clone:**
   ```bash
   git clone https://github.com/your-username/dokploy-django-template.git
   cd dokploy-django-template
   ```

2. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

3. **Make your changes:**
   - Test locally with Docker
   - Update documentation if needed
   - Ensure no secrets are committed

4. **Test your changes:**
   ```bash
   # Build Docker image
   docker build -t test-django .

   # Test locally
   docker-compose up

   # Verify health endpoint
   curl http://localhost:8001/api/health/
   ```

5. **Commit with clear messages:**
   ```bash
   git add .
   git commit -m "feat: Add Celery configuration example"
   # or
   git commit -m "fix: Correct PostgreSQL connection timeout"
   # or
   git commit -m "docs: Clarify Traefik setup steps"
   ```

6. **Push and create PR:**
   ```bash
   git push origin feature/your-feature-name
   ```

## 📝 Commit Message Convention

We use semantic commit messages:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `perf:` - Performance improvements

**Examples:**
```
feat: Add Redis caching configuration
fix: Resolve Docker network connectivity issue
docs: Add troubleshooting section for CSRF errors
chore: Update Django to 5.2.8
```

## 🚫 What NOT to Commit

- **No secrets!** (API keys, passwords, tokens)
- No `.env` files (only `.env.example` or `.env.template`)
- No `db.sqlite3` or database files
- No `__pycache__/` or `.pyc` files
- No personal/proprietary code

**Always verify before committing:**
```bash
git diff --cached
```

## ✅ Pull Request Checklist

Before submitting a PR:

- [ ] Code works locally
- [ ] No secrets or sensitive data included
- [ ] Documentation updated (if applicable)
- [ ] Commit messages are clear
- [ ] Branch is up to date with main
- [ ] Changes are focused (one feature/fix per PR)

## 🎓 Good PR Examples

### Example 1: Documentation Fix
```markdown
**Title:** docs: Fix typo in PostgreSQL setup guide

**Description:**
Changed "pg_hab.conf" to "pg_hba.conf" in POSTGRESQL_EXTERNAL_SETUP.md

**Testing:**
- [x] Verified markdown renders correctly
```

### Example 2: New Feature
```markdown
**Title:** feat: Add Celery + Redis configuration

**Description:**
Adds optional Celery task queue setup with Redis backend.

**Changes:**
- Added `docker-compose.celery.yml`
- Created `celery.py` configuration
- Updated requirements.txt with celery + redis
- Added documentation in `starter-package/docs/CELERY_SETUP.md`

**Testing:**
- [x] Tested locally with Docker
- [x] Verified task execution
- [x] Health check passes
```

## 🌍 Community Guidelines

### Be Respectful
- This is a learning community
- No question is too basic
- Be patient with newcomers
- Constructive criticism only

### Share Knowledge
- If you solved a problem, document it
- Help others in Issues/Discussions
- Share your deployment experiences

### Stay On Topic
- Keep discussions relevant to Django + Dokploy
- For general Django questions, use Django Forums
- For Dokploy issues, check Dokploy docs first

## 🏆 Recognition

Contributors will be:
- Listed in GitHub contributors
- Mentioned in release notes (for significant contributions)
- Appreciated with a ⭐ from maintainers

## 📞 Questions?

- **General questions:** Open a [Discussion](../../discussions)
- **Bug reports:** Open an [Issue](../../issues)
- **Security concerns:** Email (add your email)

## 🚀 First Time Contributors

New to open source? Perfect! This is a great place to start:

1. Look for issues labeled `good first issue`
2. Check documentation for typos or unclear sections
3. Share your deployment experience
4. Ask questions in Discussions

**We were all beginners once. Welcome aboard! 🎉**

---

Thank you for making this template better for everyone! 💚
