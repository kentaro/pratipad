defmodule Pratipad.Broadway.Forward do
  use Broadway
  require Logger
  alias Broadway.Message

  def start_link(opts \\ []) do
    Broadway.start_link(__MODULE__, [name: __MODULE__] ++ opts)
  end

  @impl Broadway
  def handle_message(_, message, context) do
    message
    |> process_message(context)
    |> Message.put_batcher(:default)
  end

  @impl Broadway
  def handle_batch(:default, messages, _batch_info, context) do
    messages
    |> send_batch(context)
  end

  defp process_message(message, context) do
    GenServer.call(context[:message_handler], {:process, message})
    |> tap(fn message ->
      Logger.debug("handle_message: #{inspect(message)}")
    end)
  end

  defp send_batch(messages, context) do
    GenServer.call(context[:output_handler], {:process, messages})
    |> tap(fn result ->
      Logger.debug("handle_batch: #{inspect(result)}")
    end)
  end
end
