defmodule Frontend.CityImportController do
  use Frontend.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", jobs: Frontend.BackgroundJob.all
  end

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    job = Enum.find Frontend.BackgroundJob.all, &(&1.id == id)

    render put_layout(conn, false), "show.html", job: job
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"city_import" => %{"file" => file}}) do
    Frontend.CityCsvJob.enqueue(file)

    redirect conn, to: city_import_path(@endpoint, :index)
  end
end
