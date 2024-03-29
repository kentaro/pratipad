defmodule Pratipad.Handler.Output do
  use GenServer
  require Logger

  @impl GenServer
  def init(opts \\ []) do
    name = opts[:name] || raise("opts[:name] is mandatory")

    :global.register_name(name, self())

    {:ok,
     %{
       server_name: opts[:server_name],
       clients: []
     }, {:continue, :init_connection}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  @impl GenServer
  def handle_continue(:init_connection, state) do
    if state.server_name do
      send(self(), :connect_to_server)
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:connect_to_server, state) do
    :global.sync()
    pid = :global.whereis_name(state.server_name)
    GenServer.cast(pid, :ready)

    # TODO: reconnect the server when it's down

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, ref, _, pid, reason}, state) do
    Logger.error(
      "[handler.output] Client down (#{inspect(reason)}): ref (#{inspect(ref)}), pid (#{inspect(pid)})"
    )

    clients = unregister_client(state.clients, pid)

    {:noreply, %{state | clients: clients}}
  end

  @impl GenServer
  def handle_call(:register, client, state) do
    {client_pid, _} = client
    Process.monitor(client_pid)
    Logger.debug("[output] register: #{inspect(client)}")

    {:reply, :ok, %{state | clients: [client | state.clients]}}
  end

  @impl GenServer
  def handle_call(:unregister, client, state) do
    {client_pid, _} = client
    clients = unregister_client(state, client_pid)
    Logger.debug("[output] unregister: #{inspect(client)}")

    {:reply, :ok, %{state | clients: clients}}
  end

  @impl GenServer
  def handle_call({:process, messages}, _from, state) do
    messages
    |> Enum.each(fn message ->
      state.clients
      |> Enum.each(fn {client_pid, _} ->
        GenServer.cast(client_pid, {:forward_message, message})
      end)
    end)

    {:reply, messages, state}
  end

  defp unregister_client(clients, client_pid) do
    clients
    |> Enum.filter(fn {pid, _} ->
      pid != client_pid
    end)
  end
end
