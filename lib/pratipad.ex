defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> {:ok, left} = Pratipad.Protocol.GenServer.start_link(%{name: :left})
      iex> {:ok, mid} = Pratipad.Protocol.GenServer.start_link(%{name: :mid})
      iex> {:ok, right} = Pratipad.Protocol.GenServer.start_link(%{name: :right})
      iex> left <|> mid <|> right
      iex> GenServer.cast(:client, {:send, [client, "hello"]})

  """
  defmacro left <|> right do
    quote do
      rname = GenServer.call(unquote(right), :name)
      GenServer.cast(rname, {:subscribe, unquote(left)})
      lname = GenServer.call(unquote(left), :name)
      GenServer.cast(lname, {:subscribe, unquote(right)})
      unquote(right)
    end
  end
end
