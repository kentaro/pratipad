defmodule Pratipad.Processor do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      @impl GenServer
      def init(_opts) do
        {:ok, nil}
      end

      def start_link(opts) do
        name = opts[:name] || __MODULE__
        GenServer.start_link(__MODULE__, opts, name: name)
      end
    end
  end
end
