defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase, async: false
  import Phoenix.ChannelTest, only: [assert_broadcast: 2]
  alias Frontend.{BackgroundJob, CsvImportJob}
  alias Backend.{City, Repo}

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :new)

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :index)

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    @endpoint.subscribe "background_job"

    conn = post conn, "/city_import", %{
      city_import: %{
        file: %Plug.Upload{
          path: "test/fixtures/cities.csv",
          filename: "cities.csv",
          content_type: "text/csv"
        }
      }
    }

    assert redirected_to(conn) == city_import_path(@endpoint, :index)

    :ok = BackgroundJob.await_all

    assert_broadcast "update", %{
      data: %{
        error: 0,
        ok: 3,
        message: nil,
        output: "/files/cities" <> _rest
      }
    }

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
    ] = BackgroundJob.all

    assert 3 == Repo.aggregate(City, :count, :id)
  end
end
