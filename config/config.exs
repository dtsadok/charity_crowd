# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :charity_crowd,
  ecto_repos: [CharityCrowd.Repo]

# Configures the endpoint
config :charity_crowd, CharityCrowdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YpJ0Yje4URp7Wnry+wAX0SubN0v/yZuW/sxVVK4pOMEJGEPIY1TR/bneJTyki25R",
  render_errors: [view: CharityCrowdWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CharityCrowd.PubSub,
  live_view: [signing_salt: "FIi4TlH0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
