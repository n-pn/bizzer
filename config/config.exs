# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bizzer,
  ecto_repos: [Bizzer.Repo]

# Configures the endpoint
config :bizzer, BizzerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "eBRRMF3nRIjbhqTbu1k5MafNNUIxHPgmeumStvzLQAteqzvv9jdHTDyc5oFy5Y3w",
  render_errors: [view: BizzerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bizzer.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :bizzer, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: BizzerWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: BizzerWeb.Endpoint
    ]
  }
