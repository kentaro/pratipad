defmodule Pratipad do
  @moduledoc """
  Documentation for `Pratipad`.
  """

  use GenServer
  require Logger

  @impl GenServer
  def init(_opts \\ []) do
    forward_config = Application.fetch_env!(:pratipad, :forward)
    backward_config = Application.fetch_env!(:pratipad, :backward)
    dataflow_module = Application.fetch_env!(:pratipad, :dataflow)

    dataflow = dataflow_module.declare()

    forward = start_broadway_for(:forward, forward_config, dataflow)
    backward = start_broadway_for(:backward, backward_config, dataflow)

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
    {:ok, message_handler} = start_message_handler(dataflow)
    {:ok, output_handler} = start_output_handler(config[:output])

    {:ok, broadway} =
      DynamicSupervisor.start_child(Pratipad.Supervisor, {
        Pratipad.Broadway.Forward,
        config[:input] ++
          [
            context: [
              message_handler: message_handler,
              output_handler: output_handler
            ]
          ]
      })

    %{
      broadway: broadway,
      message_handler: message_handler,
      output_handler: output_handler
    }
  end

  defp start_broadway_for(:backward, config, dataflow) do
    cond do
      config && dataflow.backward_enabled ->
        {:ok, output_handler} = start_output_handler(config[:output])

        {:ok, broadway} =
          DynamicSupervisor.start_child(Pratipad.Supervisor, {
            Pratipad.Broadway.Backward,
            config[:input] ++
              [
                context: [
                  output_handler: output_handler
                ]
              ]
          })

        %{
          broadway: broadway,
          output_handler: output_handler
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

  defp start_output_handler(opts) do
    DynamicSupervisor.start_child(Pratipad.Supervisor, {
      Pratipad.Handler.Output,
      opts
    })
  end
end
