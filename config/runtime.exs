import Config

http_port =
  if config_env() != :test,
    do: System.get_env("TODO_HTTP_PORT", "5454"),
    else: System.get_env("TODO_TEST_HTTP_PORT", "5455")

db_folder = if config_env() == :test, do: "./persist_test", else: "./persist"

config :data_structures,
  http_port: String.to_integer(http_port),
  db_folder: db_folder
