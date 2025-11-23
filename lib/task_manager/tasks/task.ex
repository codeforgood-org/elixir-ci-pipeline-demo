defmodule TaskManager.Tasks.Task do
  @moduledoc """
  Schema for Task entity.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          title: String.t(),
          description: String.t() | nil,
          status: String.t(),
          priority: String.t(),
          due_date: Date.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  @valid_statuses ~w(todo in_progress done)
  @valid_priorities ~w(low medium high)

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "todo"
    field :priority, :string, default: "medium"
    field :due_date, :date

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset for a task.
  """
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :due_date])
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 1000)
    |> validate_inclusion(:status, @valid_statuses)
    |> validate_inclusion(:priority, @valid_priorities)
  end

  @doc """
  Returns valid status values.
  """
  def valid_statuses, do: @valid_statuses

  @doc """
  Returns valid priority values.
  """
  def valid_priorities, do: @valid_priorities
end
