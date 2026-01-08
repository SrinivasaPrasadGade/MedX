from google.cloud import bigquery

PROJECT_ID = "medx-health-platform"
DATASET_ID = "medx_analytics"
TABLE_ID = "medication_events"

try:
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = client.dataset(DATASET_ID).table(TABLE_ID)
    table = client.get_table(table_ref)
    
    print("Current schema fields:", [f.name for f in table.schema])
    
    # Check if fields exist
    existing_fields = {f.name for f in table.schema}
    new_schema = list(table.schema)
    
    added = False
    if "event_type" not in existing_fields:
        new_schema.append(bigquery.SchemaField("event_type", "STRING", mode="NULLABLE"))
        print("Adding event_type...")
        added = True
        
    if "details" not in existing_fields:
        new_schema.append(bigquery.SchemaField("details", "STRING", mode="NULLABLE"))
        print("Adding details...")
        added = True
        
    if added:
        table.schema = new_schema
        client.update_table(table, ["schema"])
        print("✅ Schema updated successfully.")
    else:
        print("Schema already has all fields.")

except Exception as e:
    print(f"Error updating schema: {e}")
