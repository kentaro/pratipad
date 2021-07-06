defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  use GenServer

  @broadway_config Application.get_env(:pratipad, :broadway)
  @dataflow_module Application.get_env(:pratipad, :dataflow, Pratipad.Dataflow.Noop)

  def init(_opts \\ []) do
    {:ok, forward} = start_broadway()
    {:ok, message_handler} = start_message_handler()
    {:ok, batch_handler} = start_batch_handler()

    {:ok,
     %{
       broadway: %{
         forward: forward
       },
       message_handler: message_handler,
       batch_handler: batch_handler
     }}
  end

  defp start_broadway() do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Broadway,
      @broadway_config[:forward]
    })
  end

  defp start_message_handler() do
    dataflow = @dataflow_module.declare()

    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.MessageHandler,
      dataflow: dataflow
    })
  end

  defp start_batch_handler() do
    dataflow = @dataflow_module.declare()

    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.BatchHandler,
      dataflow: dataflow
    })
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end
end
