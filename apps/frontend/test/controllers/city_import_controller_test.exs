defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase, async: false
  use Frontend.JobRunnerCleanup
  alias Frontend.JobRunner

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :new)

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :index)

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    conn = post conn, city_import_path(@endpoint, :create), %{
      city_import: %{
        file: %Plug.Upload{
          path: "test/fixtures/cities.csv",
          filename: "cities.csv",
          content_type: "text/csv"
        }
      }
    }

    :ok = JobRunner.await_all

    assert 3 == Backend.City.count
    assert 1 == JobRunner.all |> Enum.count
    assert redirected_to(conn) == city_import_path(@endpoint, :index)
  end
end
