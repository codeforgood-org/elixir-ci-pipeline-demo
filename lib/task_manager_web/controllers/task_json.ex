defmodule TaskManagerWeb.TaskJSON do
  alias TaskManager.Tasks.Task

  @doc """
  Renders a paginated list of tasks.
  """
  def index(%{tasks: tasks, total: total, page: page, page_size: page_size, total_pages: total_pages}) do
    %{
      data: for(task <- tasks, do: data(task)),
      pagination: %{
        total: total,
        page: page,
        page_size: page_size,
        total_pages: total_pages
      }
    }
  end

  @doc """
  Renders task statistics.
  """
  def statistics(%{stats: stats}) do
    %{
      data: %{
        total: stats.total,
        by_status: stats.by_status,
        by_priority: stats.by_priority,
        overdue: stats.overdue
      }
    }
  end

  @doc """
  Renders a single task.
  """
  def show(%{task: task}) do
    %{data: data(task)}
  end

  defp data(%Task{} = task) do
    %{
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      due_date: task.due_date,
      inserted_at: task.inserted_at,
      updated_at: task.updated_at
    }
  end
end
