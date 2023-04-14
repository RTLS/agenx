import Config

config :agenx,
  openai_api_key: System.get_env("OPENAI_API_KEY")

config :tesla, adapter: Tesla.Adapter.Hackney
