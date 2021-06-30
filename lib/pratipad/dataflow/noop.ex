defmodule Pratipad.Dataflow.Noop do
  use Pratipad.Dataflow

  def declare() do
    Input ~> Pratipad.Processor.Noop ~> Output
  end
end
