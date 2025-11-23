defmodule TaskManagerWeb.TaskControllerTest do
  use TaskManagerWeb.ConnCase

  import TaskManager.TasksFixtures

  alias TaskManager.Tasks.Task

  @create_attrs %{
    title: "New Task",
    description: "Task description",
    status: "todo",
    priority: "high",
    due_date: ~D[2024-12-31]
  }
  @update_attrs %{
    title: "Updated Task",
    description: "Updated description",
    status: "in_progress",
    priority: "medium",
    due_date: ~D[2025-01-15]
  }
  @invalid_attrs %{title: nil, description: nil, status: "invalid", priority: "invalid"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get(conn, ~p"/api/tasks")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all tasks with data", %{conn: conn} do
      task = task_fixture()
      conn = get(conn, ~p"/api/tasks")
      response = json_response(conn, 200)["data"]

      assert length(response) == 1
      assert List.first(response)["id"] == task.id
      assert List.first(response)["title"] == task.title
    end

    test "returns tasks in descending order by insertion", %{conn: conn} do
      task1 = task_fixture(%{title: "First Task"})
      :timer.sleep(10)
      task2 = task_fixture(%{title: "Second Task"})
      :timer.sleep(10)
      task3 = task_fixture(%{title: "Third Task"})

      conn = get(conn, ~p"/api/tasks")
      response = json_response(conn, 200)["data"]

      assert length(response) == 3
      assert Enum.at(response, 0)["id"] == task3.id
      assert Enum.at(response, 1)["id"] == task2.id
      assert Enum.at(response, 2)["id"] == task1.id
    end
  end

  describe "create task" do
    test "renders task when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "title" => "New Task",
               "description" => "Task description",
               "status" => "todo",
               "priority" => "high",
               "due_date" => "2024-12-31"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders error when title is missing", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: %{description: "No title"})
      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "title")
    end

    test "creates task with minimal required data", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: %{title: "Minimal Task"})
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")
      response = json_response(conn, 200)["data"]

      assert response["title"] == "Minimal Task"
      assert response["status"] == "todo"
      assert response["priority"] == "medium"
    end

    test "sets location header on creation", %{conn: conn} do
      conn = post(conn, ~p"/api/tasks", task: @create_attrs)
      assert get_resp_header(conn, "location") != []
    end
  end

  describe "show task" do
    test "renders task when it exists", %{conn: conn} do
      task = task_fixture()
      conn = get(conn, ~p"/api/tasks/#{task.id}")

      assert %{
               "id" => id,
               "title" => _,
               "description" => _,
               "status" => _,
               "priority" => _
             } = json_response(conn, 200)["data"]

      assert id == task.id
    end

    test "renders 404 when task doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, ~p"/api/tasks/999999")
      end
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/tasks/#{id}")

      assert %{
               "id" => ^id,
               "title" => "Updated Task",
               "description" => "Updated description",
               "status" => "in_progress",
               "priority" => "medium",
               "due_date" => "2025-01-15"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "can update individual fields", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: %{status: "done"})
      assert json_response(conn, 200)["data"]["status"] == "done"
    end

    test "validates status on update", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: %{status: "invalid_status"})
      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "status")
    end

    test "validates priority on update", %{conn: conn, task: task} do
      conn = put(conn, ~p"/api/tasks/#{task}", task: %{priority: "invalid_priority"})
      assert %{"errors" => errors} = json_response(conn, 422)
      assert Map.has_key?(errors, "priority")
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, ~p"/api/tasks/#{task}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/tasks/#{task}")
      end
    end

    test "returns 404 when deleting non-existent task", %{conn: conn} do
      assert_error_sent 404, fn ->
        delete(conn, ~p"/api/tasks/999999")
      end
    end
  end

  defp create_task(_) do
    task = task_fixture()
    %{task: task}
  end
end
