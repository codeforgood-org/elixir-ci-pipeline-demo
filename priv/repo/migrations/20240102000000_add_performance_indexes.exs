defmodule TaskManager.Repo.Migrations.AddPerformanceIndexes do
  use Ecto.Migration

  def change do
    # Composite indexes for common query patterns
    create index(:tasks, [:status, :inserted_at])
    create index(:tasks, [:priority, :inserted_at])
    create index(:tasks, [:status, :priority])

    # Index for overdue tasks query
    create index(:tasks, [:due_date, :status])

    # Full-text search index for PostgreSQL (trigram index for LIKE queries)
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm", "DROP EXTENSION IF EXISTS pg_trgm"
    create index(:tasks, ["title gin_trgm_ops"], using: :gin)
    create index(:tasks, ["description gin_trgm_ops"], using: :gin)
  end
end
