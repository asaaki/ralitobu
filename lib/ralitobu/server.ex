defmodule Ralitobu.Server do
  @moduledoc """
  The GenServer - nothing special. Really.
  """

  use GenServer
  alias Ralitobu.{Bucket, Config}
  alias Ralitobu.Server.State

  @compile {:inline, server_config: 1, reply_to_target: 3}

  def start_link(config \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__,
      server_config(config),
      Dict.merge([name: __MODULE__], opts)
    )
  end

  @doc false
  defp server_config(config),
    do: Config.parse(config)

  @doc false
  def init({table_name, timeout, cleanup_rate}) do
    state = State.new(table_name, timeout, cleanup_rate)
    :timer.send_interval(state.cleanup_rate, :prune)
    {:ok, state}
  end

  # sync

  @doc false
  def handle_call({:checkout, id, limit, lifetime}, _from, state),
    do: {:reply, Bucket.checkout(state.table, id, limit, lifetime), state}

  @doc false
  def handle_call({:inspect, id, limit, lifetime}, _from, state),
    do: {:reply, Bucket.inspect(state.table, id, limit, lifetime), state}

  @doc false
  def handle_call({:delete, id}, _from, state),
    do: {:reply, Bucket.delete(state.table, id), state}

  @doc false
  def handle_call(:stop, _from, state),
    do: {:stop, :normal, :ok, state}

  # async

  @doc false
  def handle_cast({:checkout, id, limit, lifetime, pid}, state),
    do: state.table |> Bucket.checkout(id, limit, lifetime) |> reply_to_target(pid, state)

  @doc false
  def handle_cast({:inspect, id, limit, lifetime, pid}, state),
    do: state.table |> Bucket.inspect(id, limit, lifetime) |> reply_to_target(pid, state)

  @doc false
  def handle_cast({:delete, id, pid}, state),
    do: state.table |> Bucket.delete(id) |> reply_to_target(pid, state)

  defp reply_to_target(response, pid, state) do
    send(pid, response)
    {:noreply, state}
  end

  # info

  @doc false
  def handle_info(:prune, state) do
    Bucket.prune(state)
    {:noreply, state}
  end
end
