defmodule Pratipad.Broadway.Backward do
  use Broadway
  require Logger
  alias Broadway.Message

  def start_link(opts \\ []) do
    Broadway.start_link(__MODULE__, [name: __MODULE__] ++ opts)
  end

  @impl Broadway
  def handle_message(_, message, _context) do
    message
    |> Message.put_batcher(:default)
  end

  @impl Broadway
  def handle_batch(:default, messages, _batch_info, _context) do
    messages
    |> send_batch()
  end

  defp send_batch(messages) do
    GenServer.call(Pratipad.Handler.Backward, {:process, messages})
    |> tap(fn result ->
      Logger.debug("handle_batch: #{inspect(result)}")
    end)
  end
end
