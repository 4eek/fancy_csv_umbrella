defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase
  alias CsvImporter.{City, Repo}

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :new)

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :index)

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    conn = post conn, "/city_import", %{
      city_import: %{
        file: %Plug.Upload{
          path: "test/fixtures/cities.csv",
          filename: "cities.csv",
          content_type: "text/csv"
        }
      }
    }

    Process.sleep(30)

    assert [%{id: 1}] = Frontend.JobTracker.all
    assert redirected_to(conn) == city_import_path(@endpoint, :index)
    assert [
      %City{name: "Madrid"},
      %City{name: "Natal"},
      %City{name: "New York"}
    ] = (City.ordered |> Repo.all)
  end
end
