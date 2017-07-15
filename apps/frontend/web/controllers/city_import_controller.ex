defmodule Frontend.CityImportController do
  use Frontend.Web, :controller
  alias Csv.Import.Options

  @options %Options{
    headers: ~w(name url)a,
    repo: Backend.SaveRecord,
    type: Backend.City,
    max_concurrency: 10
  }
  @output_dir Application.app_dir(:frontend, ["priv", "static"])

  def index(conn, _params) do
    render conn, "index.html"
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"city_import" => %{"file" => file}}) do
    Frontend.CsvImportJob.enqueue file, @options, @output_dir

    redirect conn, to: city_import_path(@endpoint, :index)
  end
end
