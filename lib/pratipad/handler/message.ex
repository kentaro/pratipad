defmodule Pratipad.Handler.Message do
  use GenServer

  @impl GenServer
  def init(opts) do
    dataflow = opts[:dataflow]
    start_processors(dataflow.forward.processors)

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
      |> Enum.reduce(message, fn processors, message ->
        message = process_message(processors, message)
        message
      end)

    {:reply, message, state}
  end

  defp start_processors(processors) do
    processors
    |> Enum.reduce([], fn p, acc ->
      acc ++ processors_to_list(p)
    end)
    |> Enum.each(fn p ->
      p.start_link()
    end)
  end

  defp processors_to_list(processors) when is_list(processors) do
    processors
  end

  defp processors_to_list(processors) when is_tuple(processors) do
    Tuple.to_list(processors)
  end

  defp processors_to_list(processors) do
    [processors]
  end

  defp process_message(processors, message) when is_list(processors) do
    processors
    |> Enum.reduce(message, fn processor, message ->
      GenServer.call(processor, {:process, message})
    end)
  end

  defp process_message(processors, message) when is_tuple(processors) do
    Tuple.to_list(processors)
    |> Enum.map(fn processor ->
      Task.async(fn -> GenServer.call(processor, {:process, message}) end)
    end)
    |> Enum.map(&Task.await/1)

    message
  end

  defp process_message(processors, message) do
    GenServer.call(processors, {:process, message})
  end
end
