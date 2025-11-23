defmodule TaskManagerWeb.TaskController do
  use TaskManagerWeb, :controller

  alias TaskManager.Tasks
  alias TaskManager.Tasks.Task

  action_fallback TaskManagerWeb.FallbackController

  @doc """
  GET /api/tasks
  Lists all tasks with pagination, filtering, and search.

  Query parameters:
  - page: Page number (default: 1)
  - page_size: Items per page (default: 20, max: 100)
  - status: Filter by status (todo, in_progress, done)
  - priority: Filter by priority (low, medium, high)
  - search: Search in title and description
  - sort_by: Field to sort by (id, title, status, priority, due_date, inserted_at, updated_at)
  - sort_order: Sort order (asc, desc)
  - overdue: Filter overdue tasks (true/false)
  """
  def index(conn, params) do
    pagination = Tasks.list_tasks_paginated(params)
    render(conn, :index, pagination)
  end

  @doc """
  GET /api/tasks/statistics
  Returns task statistics.
  """
  def statistics(conn, _params) do
    stats = Tasks.get_task_statistics()
    render(conn, :statistics, stats: stats)
  end

  @doc """
  POST /api/tasks
  Creates a new task.
  """
  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- Tasks.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/tasks/#{task}")
      |> render(:show, task: task)
    end
  end

  @doc """
  GET /api/tasks/:id
  Shows a single task.
  """
  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    render(conn, :show, task: task)
  end

  @doc """
  PUT/PATCH /api/tasks/:id
  Updates a task.
  """
  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    with {:ok, %Task{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, :show, task: task)
    end
  end

  @doc """
  DELETE /api/tasks/:id
  Deletes a task.
  """
  def delete(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)

    with {:ok, %Task{}} <- Tasks.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
