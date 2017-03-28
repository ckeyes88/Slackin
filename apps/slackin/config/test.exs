use Mix.Config 

config :slack, Slackin.Kin,
  secret_key: System.get_env("SLACK_KEY")