# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TaskManager.Repo.insert!(%TaskManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TaskManager.Tasks

# Create sample tasks
{:ok, _task1} =
  Tasks.create_task(%{
    title: "Set up CI/CD pipeline",
    description: "Configure GitHub Actions for automated testing and deployment",
    status: "done",
    priority: "high",
    due_date: ~D[2024-01-15]
  })

{:ok, _task2} =
  Tasks.create_task(%{
    title: "Write comprehensive tests",
    description: "Add unit and integration tests with >90% coverage",
    status: "in_progress",
    priority: "high",
    due_date: ~D[2024-01-20]
  })

{:ok, _task3} =
  Tasks.create_task(%{
    title: "Add Docker support",
    description: "Create Dockerfile and docker-compose.yml for easy deployment",
    status: "todo",
    priority: "medium",
    due_date: ~D[2024-01-25]
  })

{:ok, _task4} =
  Tasks.create_task(%{
    title: "Update documentation",
    description: "Document API endpoints and setup instructions",
    status: "todo",
    priority: "low",
    due_date: ~D[2024-01-30]
  })

IO.puts("Sample tasks created successfully!")
