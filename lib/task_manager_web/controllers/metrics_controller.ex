defmodule TaskManagerWeb.MetricsController do
  use TaskManagerWeb, :controller

  @moduledoc """
  Exports Prometheus-compatible metrics for monitoring.
  """

  alias TaskManager.Tasks

  @doc """
  Returns Prometheus-formatted metrics.
  """
  def index(conn, _params) do
    stats = Tasks.get_task_statistics()

    metrics = """
    # HELP task_manager_tasks_total Total number of tasks
    # TYPE task_manager_tasks_total gauge
    task_manager_tasks_total #{stats.total}

    # HELP task_manager_tasks_by_status Number of tasks by status
    # TYPE task_manager_tasks_by_status gauge
    task_manager_tasks_by_status{status="todo"} #{Map.get(stats.by_status, "todo", 0)}
    task_manager_tasks_by_status{status="in_progress"} #{Map.get(stats.by_status, "in_progress", 0)}
    task_manager_tasks_by_status{status="done"} #{Map.get(stats.by_status, "done", 0)}

    # HELP task_manager_tasks_by_priority Number of tasks by priority
    # TYPE task_manager_tasks_by_priority gauge
    task_manager_tasks_by_priority{priority="low"} #{Map.get(stats.by_priority, "low", 0)}
    task_manager_tasks_by_priority{priority="medium"} #{Map.get(stats.by_priority, "medium", 0)}
    task_manager_tasks_by_priority{priority="high"} #{Map.get(stats.by_priority, "high", 0)}

    # HELP task_manager_tasks_overdue Number of overdue tasks
    # TYPE task_manager_tasks_overdue gauge
    task_manager_tasks_overdue #{stats.overdue}

    # HELP task_manager_up Application health status
    # TYPE task_manager_up gauge
    task_manager_up 1
    """

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, metrics)
  end
end
