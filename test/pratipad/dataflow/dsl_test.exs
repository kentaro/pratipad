defmodule Pratipad.Dataflow.DSL.Test do
  use ExUnit.Case, async: true

  use Pratipad.Dataflow.DSL
  alias Pratipad.Dataflow
  alias Pratipad.Dataflow.{Push, Demand, Pull, Forward, Output}

  describe "When a push dataflow is declared" do
    test "it can have a single processor" do
      dataflow = Push ~> TestProcessor ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false
             }
    end

    test "it can be bidirectical" do
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

  describe "When a demand dataflow is declared" do
    test "it can have a single processor" do
      dataflow = Demand ~> TestProcessor ~> Output

      assert dataflow == %Dataflow{
               mode: :pull,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: false
             }
    end

    test "it can be bidirectical" do
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

  describe "When a pull dataflow is declared" do
    test "it can have a single processor" do
      dataflow = Pull <~> TestProcessor <~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor]
               },
               backward_enabled: true
             }
    end

    test "it cannot be unidirectical" do
      assert_raise ArgumentError, "pull mode can be enabled only for bidirectional dataflow", fn ->
        Pull ~> TestProcessor ~> Output
      end
    end
  end

  describe "When a dataflow is declared" do
    test "it can have multiple processors" do
      dataflow = Push ~> TestProcessor1 ~> TestProcessor2 ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor1, TestProcessor2]
               },
               backward_enabled: false
             }
    end

    test "it can have multiple processors as a list" do
      dataflow = Push ~> [TestProcessor1, TestProcessor2] ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [[TestProcessor1, TestProcessor2]]
               },
               backward_enabled: false
             }
    end

    test "it can have multiple processors as a tuple" do
      dataflow = Push ~> {TestProcessor1, TestProcessor2} ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [{TestProcessor1, TestProcessor2}]
               },
               backward_enabled: false
             }
    end

    test "it can have multiple processors as various data structures" do
      dataflow = Push ~> TestProcessor1 ~> [TestProcessor2, TestProcessor3] ~> {TestProcessor4, TestProcessor5} ~> Output

      assert dataflow == %Dataflow{
               mode: :push,
               forward: %Forward{
                 processors: [TestProcessor1, [TestProcessor2, TestProcessor3], {TestProcessor4, TestProcessor5}]
               },
               backward_enabled: false
             }
    end
  end
end
