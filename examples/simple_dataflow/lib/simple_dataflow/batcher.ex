defmodule SimpleDataflow.Batcher do
  use Pratipad.Batcher

  def process(messages) do
    messages
    |> Enum.each(fn message ->
      Logger.debug("successfully uploaded data: #{inspect(message)}")
    end)

    messages
  end
end
