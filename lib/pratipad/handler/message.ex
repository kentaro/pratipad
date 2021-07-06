defmodule Pratipad.Handler.Message do
  use GenServer

  @impl GenServer
  def init(opts) do
    dataflow = opts[:dataflow]

    dataflow.forward.processors
    |> Enum.each(fn processor ->
      processor.start_link()
    end)

    {:ok,
     %{
       dataflow: dataflow
     }}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def handle_call({:process, message}, _from, state) do
    message =
      state.dataflow.forward.processors
      |> Enum.reduce(message, fn processor, message ->
        GenServer.call(processor, {:process, message})
      end)

    {:reply, message, state}
  end
end
