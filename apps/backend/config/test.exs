use Mix.Config

config :csv_importer, CsvImporter.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "fancy_csv_test",
  username: "thiago",
  password: "thiago",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# NOTE: Remember this
config :logger, level: :info
