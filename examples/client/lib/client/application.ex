defmodule Examples.Client.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Node.connect(:server@localhost)

    children = [
      {Examples.Client, nil}
    ]

    opts = [strategy: :one_for_one, name: SimpleDataflow.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
