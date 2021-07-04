defmodule Pratipad.Broadway do
  use Broadway

  def start_link(opts \\ []) do
    Broadway.start_link(__MODULE__, [name: __MODULE__] ++ opts)
  end

  @impl Broadway
  def handle_message(_, message, _context) do
    GenServer.call(Pratipad.MessageHandler, {:process, message})
  end
end
