defmodule JobRunnerTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = JobRunner.Server.start_link
    {:ok, pid: pid, self: self()}
  end

  test "registers one job", %{pid: pid, self: self} do
    JobRunner.add pid, %{initial: "state"}, fn(job_id) ->
      assert 1 = job_id
      send self, {:message, "job"}
    end

    assert_receive {:message, "job"}
    assert [%{id: 1, data: %{initial: "state"}}] = JobRunner.all(pid)
  end

  test "registers two jobs", %{pid: pid, self: self} do
    JobRunner.add pid, %{initial_1: "state_1"}, fn(job_id) ->
      assert 1 = job_id
      send self, {:message, "job 1"}
    end

    JobRunner.add pid, %{initial_2: "state_2"}, fn(job_id) ->
      assert 2 = job_id
      send self, {:message, "job 2"}
    end

    assert_receive {:message, "job 1"}
    assert_receive {:message, "job 2"}
    assert [
      %{id: 1, data: %{initial_1: "state_1"}},
      %{id: 2, data: %{initial_2: "state_2"}}
    ] = JobRunner.all(pid)
  end

  test "updates a job", %{pid: pid} do
    JobRunner.add pid, %{initial: "state"}, fn(_) -> nil end
    JobRunner.update pid, %{id: 1, data: %{initial: "state_2", random: "123"}}

    assert [%{id: 1, data: %{initial: "state_2", random: "123"}}] = JobRunner.all(pid)
  end

  test "merges properly while updating", %{pid: pid} do
    JobRunner.add pid, %{initial: "state"}, fn(_) -> nil end
    JobRunner.update pid, %{id: 1, data: %{initial_2: "state_2", random: "123"}}

    assert [
      %{id: 1, data: %{initial: "state", initial_2: "state_2", random: "123"}}
    ] = JobRunner.all(pid)
  end

  @tag :capture_log
  test "does not update an invalid job", %{pid: pid} do
    Process.flag :trap_exit, true

    JobRunner.add pid, %{initial: "state"}, fn(_) -> nil end
    JobRunner.update pid, %{id: 5, data: %{initial: "state_2", random: "123"}}

    assert_receive {:EXIT, ^pid, {{:badmap, _}, _}}
  end
end
