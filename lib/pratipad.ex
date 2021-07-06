defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  use GenServer

  @forward_config Application.get_env(:pratipad, :forward)
  @backward_config Application.get_env(:pratipad, :backward)
  @dataflow_module Application.get_env(:pratipad, :dataflow, Pratipad.Dataflow.Noop)

  @impl GenServer
  def init(_opts \\ []) do
    dataflow = @dataflow_module.declare()

    forward = start_broadway_for(:forward, @forward_config, dataflow)
    backward = start_broadway_for(:backward, @backward_config, dataflow)

    {:ok,
     %{
       dataflow: dataflow,
       forward: forward,
       backward: backward
     }}
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  defp start_broadway_for(:forward, config, dataflow) do
    {:ok, broadway} =
      DynamicSupervisor.start_child(Pratipad.Supervisor, {
        Pratipad.Broadway.Forward,
        config
      })

    {:ok, message_handler} = start_message_handler(dataflow)
    {:ok, batch_handler} = start_batch_handler(dataflow)

    %{
      broadway: broadway,
      message_handler: message_handler,
      batch_handler: batch_handler
    }
  end

  defp start_broadway_for(:backward, config, dataflow) do
    cond do
      config && dataflow.backward_enabled ->
        {:ok, broadway} =
          DynamicSupervisor.start_child(Pratipad.Supervisor, {
            Pratipad.Broadway.Backward,
            config
          })

        {:ok, backward_handler} = start_backward_handler()

        %{
          broadway: broadway,
          backward_handler: backward_handler
        }

      !config != !dataflow.backward_enabled ->
        raise(
          "Both the config and dataflow declaration are set in order to enable backward dataflow: #{inspect(dataflow)}"
        )

      !config && !dataflow.backward_enabled ->
        nil
    end
  end

  defp start_message_handler(dataflow) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Message,
      dataflow: dataflow
    })
  end

  defp start_batch_handler(dataflow) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Batch,
      dataflow: dataflow
    })
  end

  defp start_backward_handler() do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Backward,
      nil
    })
  end
end
