defmodule CsvImportJobTest do
  use ExUnit.Case, async: false
  alias Frontend.Endpoint
  import Phoenix.ChannelTest, only: [assert_broadcast: 2]
  alias Frontend.{BackgroundJob, CsvImportJob}
  alias Backend.{City, Repo, Csv}

  setup do
    Endpoint.subscribe "background_job"

    upload = %Plug.Upload{
      path: "test/fixtures/cities.csv",
      filename: "cities.csv",
      content_type: "text/csv"
    }
    format = %Csv.Format{headers: ~w(name url)a, type: City}
    {:ok, tmpdir} = Briefly.create(directory: true)
    {:ok, pid} = BackgroundJob.Server.start_link

    {:ok, pid: pid, format: format, upload: upload, base_dir: tmpdir}
  end

  test "imports csv and broadcasts status", %{pid: pid} = opts do
    CsvImportJob.enqueue pid, opts.upload, opts.format, opts.base_dir

    :ok = BackgroundJob.await_all(pid)

    assert 3 == Repo.aggregate(City, :count, :id)
    assert_broadcast "add", %{id: 1, data: %{filename: "cities.csv"}}
    assert_broadcast "update", %{
      data: %{
        error: 0,
        ok: 3,
        message: nil,
        output: output_dir
      }
    }
    assert File.exists?(opts.base_dir <> output_dir)
    assert [
      %{
        id: 1,
        data: %CsvImportJob{
          ok: 3,
          error: 0,
          filename: "cities.csv",
          output: "/files/cities" <> _rest
        }
      }
    ] = BackgroundJob.all(pid)

    Repo.delete_all(City)
  end
end
