defmodule CsvImporter.City do
  use Ecto.Schema

  schema "cities" do
    field :name, :string
    field :url, :string
  end

  def ordered do
    import Ecto.Query

    __MODULE__ |> order_by(asc: :name)
  end
end
