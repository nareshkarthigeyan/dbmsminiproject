# MultiService Platform (Ride + Food) — Local Demo

This repository contains a local demo of a multi-service platform: PostgreSQL schema + SQL scripts, a Django backend (raw SQL API), and a simple React frontend.

Layout
```
multiservice/
├─ db/
├─ backend/
└─ frontend/
```

Quick start

1) Start PostgreSQL and create DB:

```bash
psql -U postgres
CREATE DATABASE multiservice_db;
\q
```

2) Load DB schema and data:

```bash
psql -U postgres -d multiservice_db -f db/schema.sql
psql -U postgres -d multiservice_db -f db/functions.sql
psql -U postgres -d multiservice_db -f db/triggers.sql
psql -U postgres -d multiservice_db -f db/seed.sql
```

3) Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# (set POSTGRES_ env vars if needed)
python manage.py runserver
```

4) Frontend

```bash
cd frontend/react-app
npm install
npm start
```

Notes
- API base URL is `http://localhost:8000/api/`.
- This repo treats SQL as the source of truth; Django views use raw SQL.
- See `db/queries.sql` for sample analytic queries and transactions.
# dbmsminiproject
