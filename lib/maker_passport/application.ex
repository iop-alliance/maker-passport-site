defmodule MakerPassport.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MakerPassportWeb.Telemetry,
      MakerPassport.Repo,
      {DNSCluster, query: Application.get_env(:maker_passport, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MakerPassport.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MakerPassport.Finch},
      # Start a worker by calling: MakerPassport.Worker.start_link(arg)
      # {MakerPassport.Worker, arg},
      # Start to serve requests, typically the last entry
      MakerPassportWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MakerPassport.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MakerPassportWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
