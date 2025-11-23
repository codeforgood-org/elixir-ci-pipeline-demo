defmodule TaskManagerWeb.Router do
  use TaskManagerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskManagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug TaskManagerWeb.Plugs.RateLimiter, limit: 100, window_seconds: 60
  end

  scope "/", TaskManagerWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/dashboard", DashboardLive
  end

  # Health check and metrics routes (no authentication required)
  scope "/", TaskManagerWeb do
    pipe_through :api

    get "/health", HealthController, :index
    get "/health/detailed", HealthController, :detailed
    get "/metrics", MetricsController, :index
  end

  # API routes
  scope "/api", TaskManagerWeb do
    pipe_through :api

    get "/tasks/statistics", TaskController, :statistics
    resources "/tasks", TaskController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:task_manager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskManagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
