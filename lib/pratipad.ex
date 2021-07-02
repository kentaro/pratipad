defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  use GenServer

  @broadway_config Application.get_env(:pratipad, :broadway)
  @dataflow_module Application.get_env(:pratipad, :dataflow, Pratipad.Dataflow.Noop)

  def init(_opts \\ []) do
    {:ok, broadway} = start_broadway()
    {:ok, handler} = start_message_handler()

    {:ok,
     %{
       broadway: broadway,
       handler: handler
     }}
  end

  defp start_broadway() do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Broadway,
      @broadway_config
    })
  end

  defp start_message_handler() do
    dataflow = @dataflow_module.declare()

    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.MessageHandler,
      dataflow: dataflow
    })
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  Hello world.

  ## Examples

      iex> Pratipad.hello()
      :world

  """
  def hello do
    :world
  end
end
