defmodule SimpleDataflow.Processor do
  use Pratipad.Processor

  def process(data) do
    "[#{today()}] #{data}"
  end

  defp today() do
    dt = DateTime.utc_now()
    "#{dt.year}-#{dt.month}-#{dt.day} #{dt.hour}:#{dt.minute}:#{dt.second}"
  end
end
