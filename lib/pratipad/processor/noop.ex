defmodule Pratipad.Processor.Noop do
  use Pratipad.Processor

  def process(data) do
    data
  end
end
