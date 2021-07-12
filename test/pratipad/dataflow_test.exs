defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case, async: true

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Input, Output, Forward}

  describe "declare dataflow with module" do
    defmodule TestDataflow do
      use Pratipad.Dataflow
      alias Pratipad.Dataflow.{Input, Output}

      def declare() do
        Input ~> TestProcessor ~> TestBatcher ~> Output
      end
    end

    test "dataflow has a single processor" do
      dataflow = TestDataflow.declare()

      assert dataflow == %Dataflow{
               input: Input,
               forward: %Forward{
                 processors: [TestProcessor],
                 batcher: TestBatcher
               },
               backward_enabled: false,
               output: Output
             }
    end
  end

  describe "declare dataflow with DSL" do
    use Pratipad.Dataflow.DSL
    alias Pratipad.Dataflow
    alias Pratipad.Dataflow.{Input, Output}

    test "dataflow has a single processor" do
      dataflow = Input ~> TestProcessor ~> TestBatcher ~> Output

      assert dataflow == %Dataflow{
               input: Input,
               forward: %Forward{
                 processors: [TestProcessor],
                 batcher: TestBatcher
               },
               backward_enabled: false,
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
               backward_enabled: false,
               output: Output
             }
    end

    test "dataflow supports backward data flow" do
      dataflow = Input <~> TestProcessor <~> TestBatcher <~> Output

      assert dataflow == %Dataflow{
               input: Input,
               forward: %Forward{
                 processors: [TestProcessor],
                 batcher: TestBatcher
               },
               backward_enabled: true,
               output: Output
             }
    end
  end
end
