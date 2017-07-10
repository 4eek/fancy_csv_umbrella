defmodule Frontend.CityImportController do
  use Frontend.Web, :controller

  @format %Backend.Csv.Format{headers: ~w(name url)a, type: Backend.City}
  @output_dir "priv/static"

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"city_import" => %{"file" => file}}) do
    Frontend.CsvImportJob.enqueue file, @format, @output_dir

    redirect conn, to: city_import_path(@endpoint, :index)
  end
end
