defmodule Frontend.BackgroundJobTest do
  use ExUnit.Case
  alias Frontend.BackgroundJob

  def add_job(pid, callback) do
    self = self()
    BackgroundJob.add pid, &callback.(&1, self)
  end

  defdelegate update_job(pid, data), to: BackgroundJob, as: :update

  setup do
    {:ok, pid} = BackgroundJob.Server.start_link
    {:ok, pid: pid}
  end

  test "registers one job", %{pid: pid} do
    add_job pid, fn(job_data, self) ->
      assert %{id: 1} = job_data
      send self, "job"
    end

    assert_receive "job"
    assert [%{id: 1, pid: pid}] = BackgroundJob.all(pid)
    assert is_pid(pid)
  end

  test "registers two jobs", %{pid: pid} do
    add_job pid, fn(job_data, self) ->
      assert %{id: 1} = job_data
      send self, "job 1"
    end

    add_job pid, fn(job_data, self) ->
      assert %{id: 2} = job_data
      send self, "job 2"
    end

    assert_receive "job 1"
    assert_receive "job 2"
    assert [%{id: 2}, %{id: 1}] = BackgroundJob.all(pid)
  end

  test "updates a job", %{pid: pid} do
    add_job pid, fn(_, _) -> nil end

    update_job pid, %{id: 1, data: "random"}

    assert [%{id: 1, data: "random"}] = BackgroundJob.all(pid)
  end
end
