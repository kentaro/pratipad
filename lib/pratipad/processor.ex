defmodule Pratipad.Processor do
  @callback process(data :: term) :: data :: term

  defmacro __using__(_opts) do
    quote do
      use GenServer
      require Logger
      alias Broadway.Message

      @impl GenServer
      def init(_opts) do
        {:ok, nil}
      end

      def start_link(opts \\ []) do
        name = opts[:name] || __MODULE__
        GenServer.start_link(__MODULE__, opts, name: name)
      end

      @impl GenServer
      def handle_call({:process, message}, _from, state) do
        message =
          message
          |> Message.update_data(&process/1)

        {:reply, message, state}
      end
    end
  end
end
