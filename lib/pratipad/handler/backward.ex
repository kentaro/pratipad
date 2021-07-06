defmodule Pratipad.Handler.Backward do
  use GenServer
  require Logger

  @impl GenServer
  def init(_opts \\ []) do
    :global.register_name(__MODULE__, self())
    {:ok, %{clients: []}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def handle_call(:register, client, state) do
    {client_pid, _} = client
    Process.monitor(client_pid)
    Logger.debug("register: #{inspect(client)}")

    {:reply, :ok, %{state | clients: [client | state.clients]}}
  end

  @impl GenServer
  def handle_call(:unregister, client, state) do
    {client_pid, _} = client
    clients = unregister_client(state, client_pid)
    Logger.debug("unregister: #{inspect(client)}")

    {:reply, :ok, %{state | clients: clients}}
  end

  @impl GenServer
  def handle_call({:process, messages}, _from, state) do
    messages
    |> Enum.each(fn message ->
      state.clients
      |> Enum.each(fn client ->
        GenServer.call(client, {:backward_message, message})
      end)
    end)

    {:reply, messages, state}
  end

  @impl GenServer
  def handle_info({:DOWN, ref, _, pid, reason}, state) do
    Logger.error("Client down (#{reason}): #{inspect(ref)}, #{inspect(pid)}")
    clients = unregister_client(state.clients, pid)
    {:noreply, %{state | clients: clients}}
  end

  defp unregister_client(state, client_pid) do
    state.clients
    |> Enum.filter(fn {pid, _} ->
      pid != client_pid
    end)
  end
end
