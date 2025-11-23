# Task Manager - Phoenix CI/CD Pipeline Demo

![CI/CD Pipeline](https://github.com/codeforgood-org/elixir-ci-pipeline-demo/workflows/CI/CD%20Pipeline/badge.svg)
![Coverage](https://img.shields.io/badge/coverage-90%25-brightgreen)
![Elixir](https://img.shields.io/badge/elixir-1.15-purple)
![Phoenix](https://img.shields.io/badge/phoenix-1.7-orange)

A production-ready Phoenix application demonstrating best practices for CI/CD pipelines, comprehensive testing, code quality, and deployment strategies.

## Features

- **RESTful API**: Full CRUD operations for task management
- **Comprehensive Testing**: Unit and integration tests with >90% coverage
- **CI/CD Pipeline**: Automated testing, code quality checks, and deployment with GitHub Actions
- **Code Quality**: Credo for style, Dialyzer for types, Sobelow for security
- **Docker Ready**: Containerized deployment with docker-compose
- **Production Config**: Proper releases and secrets management
- **Test Coverage**: ExCoveralls integration with coverage reporting
- **Database Migrations**: Ecto migrations for schema management
- **LiveDashboard**: Real-time metrics and debugging in development

## Tech Stack

- **Elixir** 1.15
- **Phoenix Framework** 1.7
- **PostgreSQL** 15
- **Ecto** (Database wrapper)
- **ExUnit** (Testing)
- **ExCoveralls** (Coverage reporting)
- **Credo** (Code quality)
- **Dialyzer** (Static analysis)
- **Sobelow** (Security scanning)

## Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 26 or later
- PostgreSQL 15 or later
- Node.js 18 or later (for asset compilation)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/codeforgood-org/elixir-ci-pipeline-demo.git
cd elixir-ci-pipeline-demo
```

### 2. Install Dependencies

```bash
# Install Elixir dependencies
mix deps.get

# Install Node.js dependencies for assets
cd assets && npm install && cd ..
```

### 3. Configure Database

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit the `.env` file with your database credentials.

### 4. Setup Database

```bash
# Create and migrate the database
mix ecto.setup

# This runs:
# - ecto.create (creates the database)
# - ecto.migrate (runs migrations)
# - run priv/repo/seeds.exs (seeds sample data)
```

### 5. Start the Server

```bash
# Start Phoenix server
mix phx.server

# Or start in interactive mode
iex -S mix phx.server
```

Visit [`http://localhost:4000`](http://localhost:4000) to see the application.
API endpoints are available at [`http://localhost:4000/api`](http://localhost:4000/api).

## Development

### Running Tests

```bash
# Run all tests
mix test

# Run tests with coverage
mix coveralls

# Run tests with HTML coverage report
mix coveralls.html

# Run tests in watch mode
mix test.watch
```

### Code Quality

```bash
# Run Credo for code quality checks
mix credo --strict

# Check code formatting
mix format --check-formatted

# Fix code formatting
mix format

# Run Dialyzer for static analysis
mix dialyzer

# Run Sobelow for security scanning
mix sobelow --config
```

### Database Operations

```bash
# Create a new migration
mix ecto.gen.migration migration_name

# Run migrations
mix ecto.migrate

# Rollback last migration
mix ecto.rollback

# Reset database (drop, create, migrate, seed)
mix ecto.reset

# Check migration status
mix ecto.migrations
```

### Interactive Development

```bash
# Start IEx with your application
iex -S mix

# Reload modules after changes
recompile()

# Access LiveDashboard (when server is running)
# Visit http://localhost:4000/dev/dashboard
```

## API Documentation

See [API.md](API.md) for detailed API documentation.

### Quick API Examples

**List all tasks:**
```bash
curl http://localhost:4000/api/tasks
```

**Create a task:**
```bash
curl -X POST http://localhost:4000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"task": {"title": "My Task", "priority": "high"}}'
```

**Update a task:**
```bash
curl -X PUT http://localhost:4000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"task": {"status": "done"}}'
```

**Delete a task:**
```bash
curl -X DELETE http://localhost:4000/api/tasks/1
```

## Docker Deployment

### Using Docker Compose (Recommended)

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Building Docker Image

```bash
# Build the Docker image
docker build -t task-manager:latest .

# Run the container
docker run -p 4000:4000 \
  -e DATABASE_URL=ecto://user:pass@host/db \
  -e SECRET_KEY_BASE=your_secret_key \
  task-manager:latest
```

## CI/CD Pipeline

This project uses GitHub Actions for continuous integration and deployment.

### Pipeline Stages

1. **Setup**: Cache dependencies for faster builds
2. **Test**: Run full test suite with PostgreSQL
3. **Coverage**: Generate and upload coverage reports
4. **Code Quality**: Run Credo for style checks
5. **Formatting**: Verify code formatting
6. **Security**: Run Sobelow security scans
7. **Dialyzer**: Perform static type analysis
8. **Build Docker**: Build and cache Docker image

### Running CI Locally

```bash
# Install act (GitHub Actions local runner)
# https://github.com/nektos/act

# Run all workflows
act

# Run specific job
act -j test
```

## Project Structure

```
.
├── .github/
│   └── workflows/        # GitHub Actions CI/CD pipelines
├── assets/              # Frontend assets (JS, CSS)
├── config/              # Application configuration
├── lib/
│   ├── task_manager/    # Business logic and contexts
│   │   ├── tasks/       # Tasks domain
│   │   └── repo.ex      # Database repository
│   └── task_manager_web/
│       ├── controllers/  # API controllers
│       ├── components/   # Reusable components
│       └── router.ex     # Route definitions
├── priv/
│   ├── repo/
│   │   └── migrations/  # Database migrations
│   └── static/          # Static files
├── test/                # Test files
├── docker-compose.yml   # Docker composition
├── Dockerfile          # Production Dockerfile
└── mix.exs             # Project dependencies
```

## Configuration

### Environment Variables

Create a `.env` file for local development:

```bash
# Database
DATABASE_URL=ecto://postgres:postgres@localhost/task_manager_dev
POOL_SIZE=10

# Phoenix
SECRET_KEY_BASE=your_secret_key_base_here
PHX_HOST=localhost
PORT=4000

# Optional
ECTO_IPV6=false
```

### Generating Secrets

```bash
# Generate a secret key base
mix phx.gen.secret

# Generate a secure random string
openssl rand -base64 48
```

## Production Deployment

### Release Build

```bash
# Set environment
export MIX_ENV=prod

# Install dependencies
mix deps.get --only prod

# Compile assets
mix assets.deploy

# Build release
mix release

# Run release
_build/prod/rel/task_manager/bin/server
```

### Environment Setup

Required environment variables for production:

```bash
DATABASE_URL=ecto://user:pass@host:5432/database
SECRET_KEY_BASE=your_very_long_secret_key_base
PHX_HOST=your-domain.com
PORT=4000
```

## Monitoring and Debugging

### LiveDashboard

Access the Phoenix LiveDashboard at:
- Development: http://localhost:4000/dev/dashboard
- Production: Configure authentication before exposing

### Observability

The application includes:
- Telemetry metrics for Phoenix, Ecto, and VM
- Request logging with request IDs
- Health check endpoint (Docker)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Coding Standards

- Follow the Elixir style guide
- Run `mix format` before committing
- Ensure all tests pass: `mix test`
- Maintain test coverage above 90%
- Pass all Credo checks: `mix credo --strict`

## Testing

### Test Structure

```
test/
├── support/              # Test helpers and fixtures
│   ├── conn_case.ex     # Controller test setup
│   ├── data_case.ex     # Database test setup
│   └── fixtures/        # Test data fixtures
├── task_manager/        # Context tests
└── task_manager_web/    # Controller tests
```

### Writing Tests

```elixir
# Example test
defmodule TaskManager.TasksTest do
  use TaskManager.DataCase

  alias TaskManager.Tasks

  test "create_task/1 creates a task with valid data" do
    attrs = %{title: "Test Task", priority: "high"}
    assert {:ok, task} = Tasks.create_task(attrs)
    assert task.title == "Test Task"
  end
end
```

## Troubleshooting

### Common Issues

**Database connection error:**
```bash
# Check PostgreSQL is running
pg_isready

# Verify credentials in config/dev.exs
```

**Port already in use:**
```bash
# Change port in config/dev.exs or use:
PORT=4001 mix phx.server
```

**Asset compilation fails:**
```bash
# Reinstall node dependencies
cd assets && rm -rf node_modules && npm install && cd ..
```

**Dialyzer warnings:**
```bash
# Clean and rebuild PLT
mix dialyzer --clean
mix dialyzer --plt
```

## Performance

- Database queries use proper indexing
- Ecto preloading to avoid N+1 queries
- Connection pooling for database
- Static asset compression in production

## Security

- CSRF protection enabled
- SQL injection prevention via Ecto
- XSS protection in templates
- Security headers configured
- Regular dependency updates
- Sobelow security scanning in CI

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Phoenix Framework](https://www.phoenixframework.org/)
- Inspired by Phoenix best practices and real-world production applications
- Community contributions and feedback

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review the API documentation in [API.md](API.md)

## Roadmap

- [ ] Add authentication and authorization
- [ ] Implement WebSocket support for real-time updates
- [ ] Add pagination for task lists
- [ ] Implement task filtering and search
- [ ] Add GraphQL API alongside REST
- [ ] Deploy to production (Fly.io, Render, etc.)
- [ ] Add monitoring with AppSignal or New Relic
- [ ] Implement rate limiting
- [ ] Add API versioning
- [ ] Create admin dashboard

---

**Built with ❤️ using Elixir and Phoenix**
