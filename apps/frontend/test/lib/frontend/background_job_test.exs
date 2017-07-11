defmodule Frontend.BackgroundJobTest do
  use ExUnit.Case
  alias Frontend.BackgroundJob

  setup do
    {:ok, pid} = BackgroundJob.Server.start_link
    {:ok, pid: pid, self: self()}
  end

  test "registers one job", %{pid: pid, self: me} do
    BackgroundJob.add pid, %{initial: "state"}, fn(job_id) ->
      assert 1 = job_id
      send me, {:message, "job"}
    end

    assert_receive {:message, "job"}
    assert [%{id: 1, data: %{initial: "state"}}] = BackgroundJob.all(pid)
  end

  test "registers two jobs", %{pid: pid, self: me} do
    BackgroundJob.add pid, %{initial_1: "state_1"}, fn(job_id) ->
      assert 1 = job_id
      send :test, {:message, "job 1"}
    end

    BackgroundJob.add pid, %{initial_2: "state_2"}, fn(job_id) ->
      assert 2 = job_id
      send me, {:message, "job 2"}
    end

    assert_receive {:message, "job 1"}
    assert_receive {:message, "job 2"}
    assert [
      %{id: 1, data: %{initial_1: "state_1"}},
      %{id: 2, data: %{initial_2: "state_2"}}
    ] = BackgroundJob.all(pid)
  end

  test "updates a job", %{pid: pid} do
    BackgroundJob.add pid, %{initial: "state"}, fn(_) -> nil end
    BackgroundJob.update pid, %{id: 1, data: %{initial: "state_2", random: "123"}}

    assert [%{id: 1, data: %{initial: "state_2", random: "123"}}] = BackgroundJob.all(pid)
  end

  test "merges properly while updating", %{pid: pid} do
    BackgroundJob.add pid, %{initial: "state"}, fn(_) -> nil end
    BackgroundJob.update pid, %{id: 1, data: %{initial_2: "state_2", random: "123"}}

    assert [
      %{id: 1, data: %{initial: "state", initial_2: "state_2", random: "123"}}
    ] = BackgroundJob.all(pid)
  end

  @tag :capture_log
  test "does not update an invalid job", %{pid: pid} do
    Process.flag :trap_exit, true

    BackgroundJob.add pid, %{initial: "state"}, fn(_) -> nil end
    BackgroundJob.update pid, %{id: 5, data: %{initial: "state_2", random: "123"}}

    assert_receive {:EXIT, ^pid, {{:badmap, _}, _}}
  end
end
