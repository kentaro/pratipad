defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> {:ok, left} = Pratipad.start_protocol(Pratipad.Protocol.GenServer, %{name: :left})
      iex> {:ok, mid} = Pratipad.start_protocol(Pratipad.Protocol.GenServer, %{name: :mid})
      iex> {:ok, right} = Pratipad.start_protocol(Pratipad.Protocol.GenServer, %{name: :right})
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

  def start_protocol(protocol, options) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {protocol, options})
  end
end
