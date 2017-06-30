defmodule Frontend.CityImportControllerTest do
  use Frontend.ConnCase
  import Phoenix.ChannelTest, only: [assert_broadcast: 2]
  alias Frontend.BackgroundJob
  alias Backend.City

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :new)

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, city_import_path(@endpoint, :index)

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    @endpoint.subscribe("city_import:status")

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

    assert [%{id: 1, ok: 3, error: 0, filename: "cities.csv"}] = BackgroundJob.all

    assert_broadcast "change", %{error: 0, ok: 1, message: ""}
    assert_broadcast "change", %{error: 0, ok: 2, message: ""}
    assert_broadcast "change", %{error: 0, ok: 3, message: ""}

    assert redirected_to(conn) == city_import_path(@endpoint, :index)
    assert ["Madrid", "Natal", "New York"] == Enum.map(City.all, &(&1.name))
  end
end
