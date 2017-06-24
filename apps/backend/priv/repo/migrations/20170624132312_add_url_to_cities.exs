defmodule CsvImporter.Repo.Migrations.AddUrlToCities do
  use Ecto.Migration

  # NOTE: no clause clause matching: {:error, :invalid_message}
  #       mix compile --force
  def change do
    alter table(:cities) do
      add :url, :string
    end
  end
end
