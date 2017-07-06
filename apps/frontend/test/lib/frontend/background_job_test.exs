defmodule Frontend.BackgroundJobTest do
  use ExUnit.Case
  alias Frontend.BackgroundJob

  setup do
    Process.register self(), :test

    {:ok, pid} = BackgroundJob.Server.start_link
    {:ok, pid: pid}
  end

  test "registers one job", %{pid: pid} do
    BackgroundJob.add pid, %{initial: "state"}, fn(job_id) ->
      assert 1 = job_id
      send :test, {:message, "job"}
    end

    assert_receive {:message, "job"}
    assert [%{id: 1, data: %{initial: "state"}}] = BackgroundJob.all(pid)
  end

  test "registers two jobs", %{pid: pid} do
    BackgroundJob.add pid, %{initial_1: "state_1"}, fn(job_id) ->
      assert 1 = job_id
      send :test, {:message, "job 1"}
    end

    BackgroundJob.add pid, %{initial_2: "state_2"}, fn(job_id) ->
      assert 2 = job_id
      send :test, {:message, "job 2"}
    end

    assert_receive {:message, "job 1"}
    assert_receive {:message, "job 2"}
    assert [
      %{id: 2, data: %{initial_2: "state_2"}},
      %{id: 1, data: %{initial_1: "state_1"}}
    ] = BackgroundJob.all(pid)
  end

  test "updates a job", %{pid: pid} do
    BackgroundJob.add pid, %{initial: "state"}, fn(_) -> nil end
    BackgroundJob.update pid, 1, %{initial: "state_2", random: "123"}

    assert [
      %{id: 1, data: %{initial: "state_2", random: "123"}}
    ] = BackgroundJob.all(pid)
  end
end
