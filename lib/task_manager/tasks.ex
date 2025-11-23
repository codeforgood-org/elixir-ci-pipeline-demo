defmodule TaskManager.Tasks do
  @moduledoc """
  The Tasks context.
  Handles all business logic related to tasks.
  """

  import Ecto.Query, warn: false
  alias TaskManager.Repo
  alias TaskManager.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  @spec list_tasks() :: [Task.t()]
  def list_tasks do
    Repo.all(from t in Task, order_by: [desc: t.inserted_at])
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_task!(integer()) :: Task.t()
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_task(map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_task(Task.t(), map()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_task(Task.t()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  @spec change_task(Task.t(), map()) :: Ecto.Changeset.t()
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Returns tasks filtered by status.

  ## Examples

      iex> list_tasks_by_status("todo")
      [%Task{status: "todo"}, ...]

  """
  @spec list_tasks_by_status(String.t()) :: [Task.t()]
  def list_tasks_by_status(status) when status in ["todo", "in_progress", "done"] do
    Repo.all(from t in Task, where: t.status == ^status, order_by: [desc: t.inserted_at])
  end

  @doc """
  Returns a paginated list of tasks with filtering and sorting.

  ## Options

    * `:page` - Page number (default: 1)
    * `:page_size` - Items per page (default: 20, max: 100)
    * `:status` - Filter by status
    * `:priority` - Filter by priority
    * `:search` - Search in title and description
    * `:sort_by` - Field to sort by (default: :inserted_at)
    * `:sort_order` - Sort order :asc or :desc (default: :desc)

  ## Examples

      iex> list_tasks_paginated(%{page: 1, page_size: 10, status: "todo"})
      %{tasks: [...], total: 42, page: 1, page_size: 10, total_pages: 5}

  """
  def list_tasks_paginated(params \\ %{}) do
    page = get_param(params, :page, 1) |> max(1)
    page_size = get_param(params, :page_size, 20) |> min(100) |> max(1)
    offset = (page - 1) * page_size

    query = build_query(params)

    total = Repo.aggregate(query, :count, :id)
    total_pages = ceil(total / page_size)

    tasks =
      query
      |> apply_sorting(params)
      |> limit(^page_size)
      |> offset(^offset)
      |> Repo.all()

    %{
      tasks: tasks,
      total: total,
      page: page,
      page_size: page_size,
      total_pages: total_pages
    }
  end

  @doc """
  Returns task statistics grouped by status and priority.

  ## Examples

      iex> get_task_statistics()
      %{
        total: 42,
        by_status: %{"todo" => 10, "in_progress" => 15, "done" => 17},
        by_priority: %{"low" => 12, "medium" => 20, "high" => 10},
        overdue: 5
      }

  """
  def get_task_statistics do
    total = Repo.aggregate(Task, :count, :id)

    by_status =
      Repo.all(
        from t in Task,
          group_by: t.status,
          select: {t.status, count(t.id)}
      )
      |> Enum.into(%{})

    by_priority =
      Repo.all(
        from t in Task,
          group_by: t.priority,
          select: {t.priority, count(t.id)}
      )
      |> Enum.into(%{})

    today = Date.utc_today()

    overdue =
      Repo.aggregate(
        from(t in Task,
          where: t.due_date < ^today and t.status != "done"
        ),
        :count,
        :id
      )

    %{
      total: total,
      by_status: by_status,
      by_priority: by_priority,
      overdue: overdue
    }
  end

  # Private helper functions

  defp build_query(params) do
    Task
    |> filter_by_status(params)
    |> filter_by_priority(params)
    |> filter_by_search(params)
    |> filter_by_due_date(params)
  end

  defp filter_by_status(query, %{status: status}) when status in ["todo", "in_progress", "done"] do
    from t in query, where: t.status == ^status
  end

  defp filter_by_status(query, _), do: query

  defp filter_by_priority(query, %{priority: priority})
       when priority in ["low", "medium", "high"] do
    from t in query, where: t.priority == ^priority
  end

  defp filter_by_priority(query, _), do: query

  defp filter_by_search(query, %{search: search}) when is_binary(search) and search != "" do
    search_term = "%#{search}%"

    from t in query,
      where: ilike(t.title, ^search_term) or ilike(t.description, ^search_term)
  end

  defp filter_by_search(query, _), do: query

  defp filter_by_due_date(query, %{overdue: true}) do
    today = Date.utc_today()
    from t in query, where: t.due_date < ^today and t.status != "done"
  end

  defp filter_by_due_date(query, %{due_before: date}) do
    from t in query, where: t.due_date <= ^date
  end

  defp filter_by_due_date(query, %{due_after: date}) do
    from t in query, where: t.due_date >= ^date
  end

  defp filter_by_due_date(query, _), do: query

  defp apply_sorting(query, params) do
    sort_by = get_param(params, :sort_by, :inserted_at)
    sort_order = get_param(params, :sort_order, :desc)

    valid_fields = [:id, :title, :status, :priority, :due_date, :inserted_at, :updated_at]

    if sort_by in valid_fields and sort_order in [:asc, :desc] do
      from t in query, order_by: [{^sort_order, field(t, ^sort_by)}]
    else
      from t in query, order_by: [desc: t.inserted_at]
    end
  end

  defp get_param(params, key, default) do
    case Map.get(params, key) || Map.get(params, to_string(key)) do
      nil -> default
      value when is_binary(value) -> parse_param(key, value, default)
      value -> value
    end
  end

  defp parse_param(:page, value, default), do: String.to_integer(value) rescue (_ -> default)
  defp parse_param(:page_size, value, default), do: String.to_integer(value) rescue (_ -> default)
  defp parse_param(:sort_by, value, _default), do: String.to_existing_atom(value) rescue (_ -> :inserted_at)
  defp parse_param(:sort_order, "asc", _default), do: :asc
  defp parse_param(:sort_order, "desc", _default), do: :desc
  defp parse_param(:sort_order, _, default), do: default
  defp parse_param(:overdue, "true", _default), do: true
  defp parse_param(:overdue, _, _default), do: false
  defp parse_param(_, value, _default), do: value
end
