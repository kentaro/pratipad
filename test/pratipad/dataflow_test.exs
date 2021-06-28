defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output}

  defmodule TestDataflow do
    use Pratipad.Dataflow
    alias Pratipad.Dataflow.{Input, Output}

    def declare() do
      Input ~> TestProcessor ~> Output
    end
  end

  test "declare" do
    dataflow = TestDataflow.declare()

    assert dataflow == %Dataflow{
      input: Input,
      processors: [TestProcessor],
      output: Output
    }
  end
end
