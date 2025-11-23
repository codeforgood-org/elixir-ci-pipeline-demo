defmodule TaskManagerWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component

  @doc """
  Renders a simple error tag for form inputs.
  """
  def error(%{errors: errors} = assigns) when is_list(errors) do
    assigns = assign(assigns, :errors, errors)

    ~H"""
    <div class="text-red-600 text-sm mt-1">
      <%= for error <- @errors do %>
        <p><%= error %></p>
      <% end %>
    </div>
    """
  end

  def error(assigns) do
    ~H"""
    """
  end
end
