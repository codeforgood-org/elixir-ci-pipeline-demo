defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(%{
        title: "Sample Task #{System.unique_integer([:positive])}",
        description: "This is a sample task description",
        status: "todo",
        priority: "medium",
        due_date: Date.utc_today() |> Date.add(7)
      })
      |> TaskManager.Tasks.create_task()

    task
  end

  @doc """
  Generate multiple tasks with different statuses.
  """
  def multiple_tasks_fixture do
    [
      task_fixture(%{status: "todo", priority: "high"}),
      task_fixture(%{status: "in_progress", priority: "medium"}),
      task_fixture(%{status: "done", priority: "low"})
    ]
  end
end
