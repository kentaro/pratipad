defmodule SimpleDataflow.Dataflow do
  use Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output}

  def declare() do
    Input ~> SimpleDataflow.Processor ~> Output
  end
end
