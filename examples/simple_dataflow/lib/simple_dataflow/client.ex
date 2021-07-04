defmodule SimpleDataflow.Client do
  use OffBroadwayOtpDistribution.Client

  @impl GenServer
  def handle_cast({:push_message, message}, state) do
    GenServer.cast(state.receiver, {:push_message, message})
    {:noreply, state}
  end

  def start(opts \\ []) do
    [
      {__MODULE__, opts}
    ]
    |> Supervisor.start_link(
      strategy: :one_for_one,
      name: SimpleDataflow.Client.Supervisor
    )
  end

  def push_message(message) do
    GenServer.cast(__MODULE__, {:push_message, message})
  end
end
