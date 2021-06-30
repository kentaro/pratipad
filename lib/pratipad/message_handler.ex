defmodule Pratipad.MessageHandler do
  use GenServer

  def init(opts) do
    processors =
      opts[:dataflow].processors
      |> Enum.map(fn processor ->
        {:ok, pid} = processor.start_link()
        pid
      end)

    {:ok,
     %{
       processors: processors
     }}
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil)
  end
end
