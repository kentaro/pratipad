defmodule Pratipad.Processor do
  @callback process(message :: term(), state :: term()) :: message :: term()

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Broadway.Message

      @behaviour Pratipad.Processor

      def start_link(opts \\ []) do
        name = opts[:name] || __MODULE__
        GenServer.start_link(__MODULE__, opts, name: name)
      end

      @impl GenServer
      def handle_call({:process, message}, _from, state) do
        message =
          message
          |> Message.update_data(fn data ->
            process(data, state)
          end)

        {:reply, message, state}
      end
    end
  end
end
