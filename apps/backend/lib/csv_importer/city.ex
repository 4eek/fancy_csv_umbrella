defmodule CsvImporter.City do
  use Ecto.Schema

  schema "cities" do
    field :name, :string
    field :url, :string
  end

  def find_by_name(name) do
    import Ecto.Query

    from c in __MODULE__, where: c.name == ^name
  end
end
