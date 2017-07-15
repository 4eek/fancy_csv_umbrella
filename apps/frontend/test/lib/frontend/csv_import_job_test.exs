defmodule CsvImportJobTest do
  use Backend.Support.DbCase, async: false
  alias Frontend.Endpoint
  import Phoenix.ChannelTest, only: [assert_broadcast: 2]
  alias Frontend.CsvImportJob
  alias Backend.City

  @upload %Plug.Upload{path: "test/fixtures/cities.csv", filename: "cities.csv"}
  @options %Csv.Import.Options{headers: ~w(name url)a, type: City, repo: Backend.SaveRecord}

  setup do
    Endpoint.subscribe "job_runner"

    {:ok, tmpdir} = Briefly.create(directory: true)
    {:ok, pid} = JobRunner.start_link

    {:ok, pid: pid, base_dir: tmpdir}
  end

  test "imports csv and broadcasts status", %{pid: pid, base_dir: base_dir} do
    CsvImportJob.enqueue pid, @upload, @options, base_dir

    :ok = JobRunner.await_all(pid)

    assert 3 == City.count
    assert [%{id: 1, data: %CsvImportJob{
      ok: 3,
      error: 0,
      filename: "cities.csv",
      output: "/files/cities" <> _rest
    }}] = JobRunner.all(pid)
    assert_broadcast "add", %{id: 1, data: %{filename: "cities.csv"}}
    assert_broadcast "update", %{data: %{error: 0, ok: 3, message: nil, output: output_dir}}
    assert Path.join(base_dir, output_dir) |> File.exists?
  end
end
