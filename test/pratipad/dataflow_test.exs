defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case, async: true

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Push, Pull, Output, Forward}

  describe "declare dataflow with module" do
    defmodule TestDataflow do
      use Pratipad.Dataflow
      alias Pratipad.Dataflow.{Push, Output}

      def declare() do
        Push ~> TestProcessor ~> Output
      end
    end

    test "dataflow has a single processor" do
      dataflow = TestDataflow.declare()

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false,
               output: Output
             }
    end
  end

  describe "declare dataflow with DSL" do
    use Pratipad.Dataflow.DSL
    alias Pratipad.Dataflow
    alias Pratipad.Dataflow.{Push, Pull, Output}

    test "dataflow has a single processor" do
      dataflow = Push ~> TestProcessor ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false,
               output: Output
             }
    end

    test "dataflow has multiple processors" do
      dataflow = Push ~> TestProcessor1 ~> TestProcessor2 ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor1, TestProcessor2]
               },
               backward_enabled: false,
               output: Output
             }
    end

    test "dataflow supports backward data flow" do
      dataflow = Push <~> TestProcessor <~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: true,
               output: Output
             }
    end
  end
end
