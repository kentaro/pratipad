defmodule Pratipad.Processor.Noop do
  use Pratipad.Processor

  def handle_call({:process, msg}, state) do
    {:reply, msg, state}
  end
end
