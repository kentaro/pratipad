defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case, async: true

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output, Forward}

  describe "declare dataflow" do
    use Pratipad.Dataflow, behaviour: false
    alias Pratipad.Dataflow.{Input, Output}

    test "dataflow has a single processor" do
      dataflow = Input ~> TestProcessor ~> TestBatcher ~> Output

      assert dataflow == %Dataflow{
               input: Input,
               forward: %Forward{
                 processors: [TestProcessor],
                 batcher: TestBatcher
               },
               output: Output
             }
    end

    test "dataflow has multiple processors" do
      dataflow = Input ~> TestProcessor1 ~> TestProcessor2 ~> TestBatcher ~> Output

      assert dataflow == %Dataflow{
               input: Input,
               forward: %Forward{
                 processors: [TestProcessor1, TestProcessor2],
                 batcher: TestBatcher
               },
               output: Output
             }
    end
  end
end
