defmodule TaskManager.TasksTest do
  use TaskManager.DataCase

  alias TaskManager.Tasks

  import TaskManager.TasksFixtures

  describe "tasks" do
    alias TaskManager.Tasks.Task

    @invalid_attrs %{title: nil, description: nil, status: nil, priority: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "list_tasks/0 returns tasks ordered by insertion date descending" do
      task1 = task_fixture()
      :timer.sleep(10)
      task2 = task_fixture()
      :timer.sleep(10)
      task3 = task_fixture()

      assert Tasks.list_tasks() == [task3, task2, task1]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "get_task!/1 raises when task doesn't exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Tasks.get_task!(999_999)
      end
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{
        title: "Test Task",
        description: "Test Description",
        status: "todo",
        priority: "high",
        due_date: ~D[2024-12-31]
      }

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.title == "Test Task"
      assert task.description == "Test Description"
      assert task.status == "todo"
      assert task.priority == "high"
      assert task.due_date == ~D[2024-12-31]
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "create_task/1 with missing title returns error" do
      attrs = %{description: "No title", status: "todo"}
      assert {:error, changeset} = Tasks.create_task(attrs)
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "create_task/1 with invalid status returns error" do
      attrs = %{title: "Task", status: "invalid_status"}
      assert {:error, changeset} = Tasks.create_task(attrs)
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "create_task/1 with invalid priority returns error" do
      attrs = %{title: "Task", priority: "invalid_priority"}
      assert {:error, changeset} = Tasks.create_task(attrs)
      assert %{priority: ["is invalid"]} = errors_on(changeset)
    end

    test "create_task/1 with title too long returns error" do
      long_title = String.duplicate("a", 256)
      attrs = %{title: long_title}
      assert {:error, changeset} = Tasks.create_task(attrs)
      assert %{title: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "create_task/1 sets default status to 'todo'" do
      attrs = %{title: "Task without status"}
      assert {:ok, %Task{} = task} = Tasks.create_task(attrs)
      assert task.status == "todo"
    end

    test "create_task/1 sets default priority to 'medium'" do
      attrs = %{title: "Task without priority"}
      assert {:ok, %Task{} = task} = Tasks.create_task(attrs)
      assert task.priority == "medium"
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      update_attrs = %{
        title: "Updated Title",
        description: "Updated Description",
        status: "in_progress",
        priority: "high"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.title == "Updated Title"
      assert task.description == "Updated Description"
      assert task.status == "in_progress"
      assert task.priority == "high"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end

    test "list_tasks_by_status/1 returns only tasks with given status" do
      task_fixture(%{status: "todo"})
      task_fixture(%{status: "todo"})
      task_fixture(%{status: "in_progress"})
      task_fixture(%{status: "done"})

      todo_tasks = Tasks.list_tasks_by_status("todo")
      assert length(todo_tasks) == 2
      assert Enum.all?(todo_tasks, &(&1.status == "todo"))

      in_progress_tasks = Tasks.list_tasks_by_status("in_progress")
      assert length(in_progress_tasks) == 1
      assert Enum.all?(in_progress_tasks, &(&1.status == "in_progress"))

      done_tasks = Tasks.list_tasks_by_status("done")
      assert length(done_tasks) == 1
      assert Enum.all?(done_tasks, &(&1.status == "done"))
    end
  end
end
