defmodule Examples.Client do
  use OffBroadwayOtpDistribution.Client

  @impl GenServer
  def handle_cast(:request_message, state) do
    Logger.info("received: :request_message")
    GenServer.cast(state.receiver, {:respond_to_pull_request, "I'm alive!"})

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:push_message, message}, state) do
    GenServer.cast(state.receiver, {:push_message, message})
    {:noreply, state}
  end

  def push_message(message) do
    GenServer.cast(__MODULE__, {:push_message, message})
  end
end
