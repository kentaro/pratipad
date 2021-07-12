defmodule Pratipad.Dataflow.Noop do
  use Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output}

  def declare() do
    Input ~> Pratipad.Processor.Noop ~> Output
  end
end
