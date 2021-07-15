defmodule SimpleDataflow.Dataflow do
  use Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output}
  alias SimpleDataflow.Processor

  def declare() do
    Input <~> Processor <~> Output
  end
end
