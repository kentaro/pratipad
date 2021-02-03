defmodule Pratipad.Protocol.GenServer do
  use GenServer

  @impl true
  def init(state) do
    {:ok, state}
  end

  def start_link(options) do
    state = %{options: options, subscribers: []}
    GenServer.start_link(__MODULE__, state, name: options.name)
  end

  @impl true
  def handle_call(:name, _from, state) do
    {:reply, state.options.name, state}
  end

  @impl true
  def handle_cast({:subscribe, pid}, state) do
    state = Map.put(state, :subscribers, [pid | state.subscribers])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:send, data}, state) do
    state.subscribers
    |> Enum.each(&(publish(&1, [self(), self(), data])))
    {:noreply, state}
  end

  @impl true
  def handle_info({:publish, [sender, relayer, data]}, state) do
    state.subscribers
    |> Enum.filter(&(&1 != relayer))
    |> Enum.each(&(publish(&1, [sender, self(), data])))
    IO.puts("#{state.options.name} received message `#{data}` from #{inspect(sender)} via #{inspect(relayer)}")
    {:noreply, state}
  end

  def publish(subscriber, [sender, relayer, data]) do
    send(subscriber, {:publish, [sender, relayer, data]})
  end
end
