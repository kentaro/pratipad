defmodule Pratipad.Dataflow.DSL.Test do
  use ExUnit.Case, async: true

  use Pratipad.Dataflow.DSL
  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Push, Demand, Forward}

  describe "declare push dataflow with DSL" do
    test "dataflow has a single processor" do
      dataflow = Push ~> TestProcessor ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false
             }
    end

    test "dataflow has multiple processors" do
      dataflow = Push ~> TestProcessor1 ~> TestProcessor2 ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor1, TestProcessor2]
               },
               backward_enabled: false
             }
    end

    test "dataflow supports backward data flow" do
      dataflow = Push <~> TestProcessor <~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: true
             }
    end
  end

  describe "declare demand dataflow with DSL" do
    test "dataflow has a single processor" do
      dataflow = Demand ~> TestProcessor ~> Output

      assert dataflow == %Dataflow{
               mode: :pull,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false
             }
    end

    test "dataflow has multiple processors" do
      dataflow = Demand ~> TestProcessor1 ~> TestProcessor2 ~> Output

      assert dataflow == %Dataflow{
               mode: :pull,
               forward: %Forward{
                 processors: [TestProcessor1, TestProcessor2]
               },
               backward_enabled: false
             }
    end

    test "dataflow supports backward data flow" do
      dataflow = Demand <~> TestProcessor <~> Output

      assert dataflow == %Dataflow{
               mode: :pull,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: true
             }
    end
  end
end
