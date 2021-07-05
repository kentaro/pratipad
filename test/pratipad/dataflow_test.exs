defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output, Forward}

  defmodule TestDataflow do
    use Pratipad.Dataflow
    alias Pratipad.Dataflow.{Input, Output}

    def declare() do
      Input ~> TestProcessor ~> TestBatcher ~> Output
    end
  end

  test "declare" do
    dataflow = TestDataflow.declare()

    assert dataflow == %Dataflow{
             input: Input,
             forward: %Forward{
               processors: [TestProcessor],
               batcher: TestBatcher
             },
             output: Output
           }
  end
end
