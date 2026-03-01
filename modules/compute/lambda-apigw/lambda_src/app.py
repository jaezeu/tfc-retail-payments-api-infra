import json
import os
import boto3

ddb = boto3.resource("dynamodb")
TABLE = os.environ["DDB_TABLE_NAME"]

def _resp(status, body):
  return {
    "statusCode": status,
    "headers": {"content-type": "application/json"},
    "body": json.dumps(body),
  }

def handler(event, context):
  table = ddb.Table(TABLE)

  path = (event.get("rawPath") or "/")
  method = (event.get("requestContext", {}).get("http", {}).get("method") or "GET")

  # Simple health
  if path == "/" and method == "GET":
    return _resp(200, {"ok": True, "env": os.environ.get("ENV"), "table": TABLE})

  # Example: PUT /items/{id}
  if path.startswith("/items/") and method == "PUT":
    item_id = path.split("/items/")[1]
    body = event.get("body") or "{}"
    payload = json.loads(body)
    table.put_item(Item={"pk": item_id, "payload": payload})
    return _resp(200, {"saved": item_id})

  # Example: GET /items/{id}
  if path.startswith("/items/") and method == "GET":
    item_id = path.split("/items/")[1]
    res = table.get_item(Key={"pk": item_id})
    return _resp(200, {"item": res.get("Item")})

  return _resp(404, {"error": "not found", "path": path, "method": method})