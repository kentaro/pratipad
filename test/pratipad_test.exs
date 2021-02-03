defmodule PratipadTest do
  use ExUnit.Case
  doctest Pratipad

  test "greets the world" do
    assert Pratipad.hello() == :world
  end
end
