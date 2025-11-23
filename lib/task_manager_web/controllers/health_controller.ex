defmodule TaskManagerWeb.HealthController do
  use TaskManagerWeb, :controller

  @moduledoc """
  Health check endpoint for monitoring and load balancers.
  """

  @doc """
  Returns a simple health check response.
  Useful for Docker health checks and load balancers.
  """
  def index(conn, _params) do
    json(conn, %{
      status: "healthy",
      service: "task_manager",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
  end

  @doc """
  Returns detailed health information including database connectivity.
  """
  def detailed(conn, _params) do
    db_status = check_database()
    app_status = check_application()

    overall_status =
      if db_status == :ok and app_status == :ok, do: "healthy", else: "unhealthy"

    status_code = if overall_status == "healthy", do: 200, else: 503

    conn
    |> put_status(status_code)
    |> json(%{
      status: overall_status,
      service: "task_manager",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      checks: %{
        database: db_status,
        application: app_status
      },
      version: Application.spec(:task_manager, :vsn) |> to_string()
    })
  end

  defp check_database do
    try do
      case Ecto.Adapters.SQL.query(TaskManager.Repo, "SELECT 1", []) do
        {:ok, _} -> :ok
        {:error, _} -> :error
      end
    rescue
      _ -> :error
    end
  end

  defp check_application do
    case Process.whereis(TaskManager.Repo) do
      nil -> :error
      _pid -> :ok
    end
  end
end
