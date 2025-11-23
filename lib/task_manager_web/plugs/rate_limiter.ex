defmodule TaskManagerWeb.Plugs.RateLimiter do
  @moduledoc """
  Simple rate limiting plug to prevent API abuse.

  This is a basic implementation using ETS. For production use with multiple
  nodes, consider using a distributed solution like Redis with Hammer or
  ex_rated.
  """

  import Plug.Conn
  require Logger

  @table_name :rate_limiter
  @default_limit 100
  @default_window_seconds 60

  def init(opts) do
    limit = Keyword.get(opts, :limit, @default_limit)
    window_seconds = Keyword.get(opts, :window_seconds, @default_window_seconds)

    # Create ETS table if it doesn't exist
    unless :ets.whereis(@table_name) != :undefined do
      :ets.new(@table_name, [:named_table, :public, :set])
    end

    %{limit: limit, window_seconds: window_seconds}
  end

  def call(conn, opts) do
    key = get_rate_limit_key(conn)
    now = System.system_time(:second)
    window_start = now - opts.window_seconds

    # Clean up old entries and count recent requests
    count = count_and_cleanup(key, window_start, now)

    cond do
      count >= opts.limit ->
        conn
        |> put_resp_header("x-ratelimit-limit", to_string(opts.limit))
        |> put_resp_header("x-ratelimit-remaining", "0")
        |> put_resp_header("x-ratelimit-reset", to_string(now + opts.window_seconds))
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.put_view(json: TaskManagerWeb.ErrorJSON)
        |> Phoenix.Controller.render(:"429")
        |> halt()

      true ->
        # Add current request
        :ets.insert(@table_name, {{key, now}, now})

        remaining = opts.limit - count - 1

        conn
        |> put_resp_header("x-ratelimit-limit", to_string(opts.limit))
        |> put_resp_header("x-ratelimit-remaining", to_string(max(remaining, 0)))
        |> put_resp_header("x-ratelimit-reset", to_string(now + opts.window_seconds))
    end
  end

  defp get_rate_limit_key(conn) do
    # Use IP address as the key
    # In production, you might want to use an API key or authenticated user ID
    conn.remote_ip
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp count_and_cleanup(key, window_start, now) do
    # Get all entries for this key
    pattern = {{key, :"$1"}, :"$2"}
    guard = [{:<, :"$1", window_start}]

    # Delete old entries
    :ets.select_delete(@table_name, [{pattern, guard, [true]}])

    # Count current entries
    pattern = {{key, :"$1"}, :"$2"}
    guard = [{:>=, :"$1", window_start}, {:"=<", :"$1", now}]
    :ets.select_count(@table_name, [{pattern, guard, [true]}])
  end
end
