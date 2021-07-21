defmodule Pratipad.Dataflow.Test do
  use ExUnit.Case, async: true

  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Push, Pull, Output, Forward}

  describe "declare dataflow with a module" do
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
end
