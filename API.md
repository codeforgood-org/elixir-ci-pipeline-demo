# Task Manager API Documentation

## Base URL

```
http://localhost:4000/api
```

## Endpoints

### Tasks

#### List All Tasks

Get a list of all tasks.

**Request:**
```http
GET /api/tasks
```

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "title": "Sample Task",
      "description": "Task description",
      "status": "todo",
      "priority": "medium",
      "due_date": "2024-12-31",
      "inserted_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### Get a Single Task

Retrieve details of a specific task.

**Request:**
```http
GET /api/tasks/:id
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "title": "Sample Task",
    "description": "Task description",
    "status": "todo",
    "priority": "medium",
    "due_date": "2024-12-31",
    "inserted_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**Error Response:** `404 Not Found`
```json
{
  "errors": {
    "detail": "Not Found"
  }
}
```

#### Create a Task

Create a new task.

**Request:**
```http
POST /api/tasks
Content-Type: application/json

{
  "task": {
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "priority": "high",
    "due_date": "2024-12-31"
  }
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "priority": "high",
    "due_date": "2024-12-31",
    "inserted_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**Error Response:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "title": ["can't be blank"],
    "status": ["is invalid"]
  }
}
```

#### Update a Task

Update an existing task.

**Request:**
```http
PUT /api/tasks/:id
Content-Type: application/json

{
  "task": {
    "title": "Updated Task",
    "status": "in_progress"
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "title": "Updated Task",
    "description": "Task description",
    "status": "in_progress",
    "priority": "high",
    "due_date": "2024-12-31",
    "inserted_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  }
}
```

**Error Response:** `422 Unprocessable Entity`
```json
{
  "errors": {
    "status": ["is invalid"]
  }
}
```

#### Delete a Task

Delete a task.

**Request:**
```http
DELETE /api/tasks/:id
```

**Response:** `204 No Content`

**Error Response:** `404 Not Found`

## Data Models

### Task

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | integer | Auto-generated | - | Unique identifier |
| `title` | string | Yes | - | Task title (max 255 chars) |
| `description` | string | No | null | Task description (max 1000 chars) |
| `status` | string | No | "todo" | Task status: `todo`, `in_progress`, or `done` |
| `priority` | string | No | "medium" | Task priority: `low`, `medium`, or `high` |
| `due_date` | date | No | null | Due date in ISO 8601 format (YYYY-MM-DD) |
| `inserted_at` | datetime | Auto-generated | - | Creation timestamp |
| `updated_at` | datetime | Auto-generated | - | Last update timestamp |

## Validation Rules

### Task Creation/Update

- **title**: Required, minimum 1 character, maximum 255 characters
- **description**: Optional, maximum 1000 characters
- **status**: Must be one of: `todo`, `in_progress`, `done`
- **priority**: Must be one of: `low`, `medium`, `high`
- **due_date**: Must be a valid date in ISO 8601 format

## Error Handling

The API uses standard HTTP status codes:

- `200 OK`: Successful GET or PUT request
- `201 Created`: Successful POST request
- `204 No Content`: Successful DELETE request
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation error

Error responses follow this format:
```json
{
  "errors": {
    "field_name": ["error message"]
  }
}
```

## Example Usage

### Using cURL

**Create a task:**
```bash
curl -X POST http://localhost:4000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "title": "Complete documentation",
      "description": "Finish writing API docs",
      "status": "todo",
      "priority": "high",
      "due_date": "2024-12-31"
    }
  }'
```

**Get all tasks:**
```bash
curl http://localhost:4000/api/tasks
```

**Update a task:**
```bash
curl -X PUT http://localhost:4000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "task": {
      "status": "done"
    }
  }'
```

**Delete a task:**
```bash
curl -X DELETE http://localhost:4000/api/tasks/1
```

## Rate Limiting

Currently, there are no rate limits applied to the API. In production, consider implementing rate limiting to protect against abuse.

## Authentication

This demo API does not implement authentication. For production use, consider adding:
- JWT tokens
- API keys
- OAuth 2.0

## CORS

CORS is not configured by default. If you need to access this API from a web browser, you'll need to configure CORS in your Phoenix application.
