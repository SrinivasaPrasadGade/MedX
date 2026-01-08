from google.cloud import bigquery
import os

PROJECT_ID = "medx-health-platform"
DATASET_ID = "medx_analytics"
TABLE_ID = "medication_events"

try:
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = client.dataset(DATASET_ID).table(TABLE_ID)
    table = client.get_table(table_ref)
    
    print(f"Schema for {TABLE_ID}:")
    for field in table.schema:
        print(f" - {field.name}: {field.field_type}")

except Exception as e:
    print(f"Error getting table: {e}")
