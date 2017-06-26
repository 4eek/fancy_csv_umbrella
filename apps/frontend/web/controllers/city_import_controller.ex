defmodule Frontend.CityImportController do
  use Frontend.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"file" => file}) do
    Frontend.CityCsvJob.enqueue(file)

    redirect conn, to: city_import_path(@endpoint, :index)
  end
end
