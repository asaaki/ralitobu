defmodule Ralitobu.Server.State do
  @moduledoc """
  Holds the server state as struct, just for convenience.
  """

  @default_timeout 90_000_000
  @default_cleanup_rate 60_000
  @default_table :ralitobu_table
  @table_options [:named_table, :set, :private]

  defstruct ~w(table timeout cleanup_rate)a

  @doc false
  def new(table_name, timeout, cleanup_rate) do
    %__MODULE__{
      timeout: timeout,
      cleanup_rate: cleanup_rate,
      table: table_name |> open_table
    }
  end

  defp open_table(table_name),
    do: :ets.new(table_name, @table_options)
end
