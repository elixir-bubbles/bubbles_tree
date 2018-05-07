use Mix.Config

config :bubbles_tree, ecto_repos: [Bubbles.Tree.Test.Repo]

config :bubbles_tree, Bubbles.Tree.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: "example_test",
  hostname: System.get_env("DB_HOSTNAME")

config :logger, :console, level: :error6
