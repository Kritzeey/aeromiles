from pathlib import Path
from django.db import migrations

SQL_DIR = Path(__file__).resolve().parent

def read_file(filename):
    return (SQL_DIR / filename).read_text()

class Migration(migrations.Migration):
    initial = True

    dependencies = []

    operations = [
        migrations.RunSQL(
            sql=read_file("migrate.sql")
        ),
    ]
