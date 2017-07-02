defmodule Frontend.BackgroundJobTest do
  use ExUnit.Case
  alias Frontend.BackgroundJob

  setup do
    Process.register self(), :test

    {:ok, pid} = BackgroundJob.Server.start_link
    {:ok, pid: pid}
  end

  test "registers one job", %{pid: pid} do
    BackgroundJob.add pid, fn(job_data) ->
      assert %{id: 1} = job_data
      send :test, {:message, "job"}
    end

    assert_receive {:message, "job"}
    assert [%{id: 1}] = BackgroundJob.all(pid)
  end

  test "registers two jobs", %{pid: pid} do
    BackgroundJob.add pid, fn(job_data) ->
      assert %{id: 1} = job_data
      send :test, {:message, "job 1"}
    end

    BackgroundJob.add pid, fn(job_data) ->
      assert %{id: 2} = job_data
      send :test, {:message, "job 2"}
    end

    assert_receive {:message, "job 1"}
    assert_receive {:message, "job 2"}
    assert [%{id: 2}, %{id: 1}] = BackgroundJob.all(pid)
  end

  test "updates a job", %{pid: pid} do
    BackgroundJob.add pid, fn(_) -> nil end
    BackgroundJob.update pid, %{id: 1, data: "random"}

    assert [%{id: 1, data: "random"}] = BackgroundJob.all(pid)
  end
end
