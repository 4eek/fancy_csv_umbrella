defmodule Frontend.CityImportControllerTest do
  require IEx
  use Frontend.ConnCase

  test "GET /city_import/new", %{conn: conn} do
    conn = get conn, "/city_import/new"

    assert html_response(conn, 200)
  end

  test "GET /city_import", %{conn: conn} do
    conn = get conn, "/city_import"

    assert html_response(conn, 200)
  end

  test "POST /city_import", %{conn: conn} do
    conn = post conn, "/city_import"

    assert redirected_to(conn) == city_import_path(@endpoint, :index)
  end
end
