defmodule SimpleDataflow.Dataflow do
  use Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output}
  alias SimpleDataflow.{Processor, Batcher}

  def declare() do
    Input <~> Processor <~> Batcher <~> Output
  end
end
