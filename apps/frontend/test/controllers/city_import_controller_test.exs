defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase, async: false
  alias Frontend.BackgroundJob

  setup do
    on_exit fn ->
      BackgroundJob.delete_all
    end

    :ok
  end

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
    :ok = BackgroundJob.await_all

    assert redirected_to(conn) == city_import_path(@endpoint, :index)
    assert 1 == BackgroundJob.all |> Enum.count
  end
end
