defmodule SimpleDataflowTest do
  use ExUnit.Case
  doctest SimpleDataflow

  test "greets the world" do
    assert SimpleDataflow.hello() == :world
  end
end
