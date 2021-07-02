defmodule Pratipad.MessageHandler do
  use GenServer

  @impl GenServer
  def init(opts) do
    dataflow = opts[:dataflow]

    dataflow.processors
    |> Enum.each(fn processor ->
      processor.start_link()
    end)

    {:ok,
     %{
       dataflow: dataflow
     }}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def handle_call({:process, message}, _from, state) do
    message =
      state.dataflow.processor
      |> Enum.reduce(message, fn processor, message ->
        GenServer.call(processor, {:process, message})
      end)

    {:reply, message, state}
  end
end
