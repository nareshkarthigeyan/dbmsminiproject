Django backend for the multiservice project

Setup:

1. Create virtualenv and install dependencies:

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

2. Update database credentials in `multiservice_django/settings.py` or set env vars: POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD

3. Start server:

python manage.py runserver

The API base is at http://localhost:8000/api/

Endpoints:
GET /api/restaurants/
GET /api/restaurants/<id>/menu/
POST /api/orders/    (payload: {user_id, restaurant_id, items: [{item_id, quantity, unit_price}], mode})
GET /api/orders/<id>/
POST /api/rides/     (payload: {user_id, source, destination, fare})

Notes:
- This backend uses raw SQL via Django's connection.cursor(); the DB is the source of truth.
- Ensure you have run the SQL scripts in `db/` to create schema and seed data before using the API.
