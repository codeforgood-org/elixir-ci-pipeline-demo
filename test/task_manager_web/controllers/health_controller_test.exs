defmodule TaskManagerWeb.HealthControllerTest do
  use TaskManagerWeb.ConnCase

  describe "index/2" do
    test "returns healthy status", %{conn: conn} do
      conn = get(conn, ~p"/health")
      response = json_response(conn, 200)

      assert response["status"] == "healthy"
      assert response["service"] == "task_manager"
      assert Map.has_key?(response, "timestamp")
    end

    test "returns valid timestamp format", %{conn: conn} do
      conn = get(conn, ~p"/health")
      response = json_response(conn, 200)

      # Verify timestamp is in ISO8601 format
      assert {:ok, _, _} = DateTime.from_iso8601(response["timestamp"])
    end
  end

  describe "detailed/2" do
    test "returns detailed health status with all checks", %{conn: conn} do
      conn = get(conn, ~p"/health/detailed")
      response = json_response(conn, 200)

      assert response["status"] == "healthy"
      assert response["service"] == "task_manager"
      assert Map.has_key?(response, "timestamp")
      assert Map.has_key?(response, "checks")
      assert Map.has_key?(response, "version")
    end

    test "includes database check status", %{conn: conn} do
      conn = get(conn, ~p"/health/detailed")
      response = json_response(conn, 200)

      assert response["checks"]["database"] == "ok"
    end

    test "includes application check status", %{conn: conn} do
      conn = get(conn, ~p"/health/detailed")
      response = json_response(conn, 200)

      assert response["checks"]["application"] == "ok"
    end

    test "returns 200 when all systems are healthy", %{conn: conn} do
      conn = get(conn, ~p"/health/detailed")
      assert conn.status == 200
    end
  end
end
