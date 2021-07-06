defmodule Pratipad.BatchHandler do
  use GenServer

  @impl GenServer
  def init(opts) do
    dataflow = opts[:dataflow]
    batcher = dataflow.forward.batcher
    batcher.start_link()

    {:ok,
     %{
       batcher: batcher
     }}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def handle_call({:process, messages}, _from, state) do
    messages = GenServer.call(state.batcher, {:process, messages})
    {:reply, messages, state}
  end
end
