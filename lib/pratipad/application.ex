defmodule Pratipad.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    [
      strategy: :one_for_one,
      name: Pratipad.Supervisor
    ]
    |> DynamicSupervisor.start_link()
  end
end
