# Models are intentionally minimal — this project treats SQL as the source of truth.
from django.db import models

# Optionally define Django models with managed = False if you want to use ORM inspections.

class Dummy(models.Model):
    class Meta:
        managed = False
        db_table = 'dummy'
