defmodule Backend.Repo.Migrations.AddCitiesTable do
  use Ecto.Migration

  def change do
    create table(:cities) do
      add :name, :string
    end
  end
end
