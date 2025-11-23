defmodule TaskManagerWeb.DashboardLive do
  use TaskManagerWeb, :live_view

  alias TaskManager.Tasks

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Update every 5 seconds
      :timer.send_interval(5000, self(), :update)
    end

    {:ok, assign_stats(socket)}
  end

  @impl true
  def handle_info(:update, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    stats = Tasks.get_task_statistics()
    recent_tasks = Tasks.list_tasks_paginated(%{page: 1, page_size: 10})

    socket
    |> assign(:stats, stats)
    |> assign(:recent_tasks, recent_tasks.tasks)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-6">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="md:flex md:items-center md:justify-between">
          <div class="flex-1 min-w-0">
            <h2 class="text-2xl font-bold leading-7 text-gray-900 sm:text-3xl sm:truncate">
              Task Dashboard
            </h2>
          </div>
          <div class="mt-4 flex md:mt-0 md:ml-4">
            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
              <span class="mr-2">●</span> Live
            </span>
          </div>
        </div>

        <!-- Statistics Cards -->
        <div class="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg
                    class="h-6 w-6 text-gray-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                    />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Total Tasks
                    </dt>
                    <dd class="text-3xl font-semibold text-gray-900">
                      <%= @stats.total %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg
                    class="h-6 w-6 text-blue-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      In Progress
                    </dt>
                    <dd class="text-3xl font-semibold text-gray-900">
                      <%= Map.get(@stats.by_status, "in_progress", 0) %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg
                    class="h-6 w-6 text-green-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Completed
                    </dt>
                    <dd class="text-3xl font-semibold text-gray-900">
                      <%= Map.get(@stats.by_status, "done", 0) %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <svg
                    class="h-6 w-6 text-red-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">
                      Overdue
                    </dt>
                    <dd class="text-3xl font-semibold text-gray-900">
                      <%= @stats.overdue %>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Tasks -->
        <div class="mt-8">
          <div class="bg-white shadow overflow-hidden sm:rounded-md">
            <div class="px-4 py-5 sm:px-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                Recent Tasks
              </h3>
            </div>
            <ul role="list" class="divide-y divide-gray-200">
              <%= for task <- @recent_tasks do %>
                <li>
                  <div class="px-4 py-4 sm:px-6 hover:bg-gray-50">
                    <div class="flex items-center justify-between">
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-indigo-600 truncate">
                          <%= task.title %>
                        </p>
                        <p class="mt-1 text-sm text-gray-500">
                          <%= task.description || "No description" %>
                        </p>
                      </div>
                      <div class="ml-4 flex-shrink-0 flex">
                        <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{status_color(task.status)}"}>
                          <%= task.status %>
                        </span>
                        <span class={"ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{priority_color(task.priority)}"}>
                          <%= task.priority %>
                        </span>
                      </div>
                    </div>
                    <div class="mt-2 flex justify-between">
                      <div class="flex items-center text-sm text-gray-500">
                        <svg
                          class="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400"
                          fill="none"
                          stroke="currentColor"
                          viewBox="0 0 24 24"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                          />
                        </svg>
                        <%= if task.due_date do %>
                          Due: <%= Calendar.strftime(task.due_date, "%B %d, %Y") %>
                        <% else %>
                          No due date
                        <% end %>
                      </div>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp status_color("todo"), do: "bg-gray-100 text-gray-800"
  defp status_color("in_progress"), do: "bg-blue-100 text-blue-800"
  defp status_color("done"), do: "bg-green-100 text-green-800"
  defp status_color(_), do: "bg-gray-100 text-gray-800"

  defp priority_color("low"), do: "bg-gray-100 text-gray-800"
  defp priority_color("medium"), do: "bg-yellow-100 text-yellow-800"
  defp priority_color("high"), do: "bg-red-100 text-red-800"
  defp priority_color(_), do: "bg-gray-100 text-gray-800"
end
