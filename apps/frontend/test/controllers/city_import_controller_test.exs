defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase, async: false
  import Phoenix.ChannelTest, only: [assert_broadcast: 2]
  alias Frontend.{BackgroundJob, CityCsvJob}
  alias Backend.{City, Repo}

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :new)

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :index)

    assert html_response(conn, 200)
  end

  test "GET /city_import/id", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :show, 1)

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    @endpoint.subscribe "city_import:status"

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

    assert_broadcast "change", %{error: 0, ok: 1, message: nil, output: nil}
    assert_broadcast "change", %{error: 0, ok: 2, message: nil, output: nil}
    assert_broadcast "change", %{error: 0, ok: 3, message: nil, output: "/files/cities" <> _rest}

    assert [
      %{id: 1,
        data: %CityCsvJob{
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
