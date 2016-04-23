defmodule Ralitobu.Bucket do
  @moduledoc """
  Server bucket logic
  """

  alias Ralitobu.Bucket.State
  alias Ralitobu.Utils

  @doc false
  def checkout(table, id, limit, lifetime),
    do: call(:checkout, table, id, limit, lifetime)

  @doc false
  def inspect(table, id, limit, lifetime),
    do: call(:inspect, table, id, limit, lifetime)

  @doc false
  def delete(table, id) do
    mspec = Utils.match_spec(:delete, id)
    case :ets.select_delete(table, mspec) do
      1 -> :ok
      _ -> :error
    end
  end

  @doc false
  def prune(%{timeout: timeout, table: table} = _state) do
    mspec = Utils.match_spec(:prune, Utils.ts, timeout)
    :ets.select_delete(table, mspec)
  end

  defp call(action, table, id, limit, lifetime) do
    {action, table, id, limit, lifetime}
    |> init_call_state
    |> find_key
    |> maybe_checkout
    |> inspect_bucket
  end

  defp init_call_state({action, table, id, limit, lifetime}),
    do: State.init(action, table, id, limit, lifetime)

  defp find_key(%{table: table, key: key} = state),
    do: %State{state | key_found: :ets.member(table, key)}

  defp maybe_checkout(%{action: :checkout} = state),
    do: state |> maybe_do_checkout
  defp maybe_checkout(state),
    do: state

  defp maybe_do_checkout(%{key_found: false} = state) do
    true =
      :ets.insert(
        state.table,
        {state.key, 1, state.timestamp, state.timestamp}
      )
    %State{state | key_found: true} # we inserted it right now ;-)
  end
  defp maybe_do_checkout(%{key_found: true} = state) do
    # http://erlang.org/doc/man/ets.html#update_counter-3
    # {2, 1}        :: Increment counter by 1,
    # {3, 0}        :: increment created_at by 0 (no-op),
    # {4, 1, 0, ts} :: and updated_at to current timestamp
    :ets.update_counter(
      state.table,
      state.key,
      [{2, 1}, {3, 0}, {4, 1, 0, state.timestamp}]
    )
    state
  end

  defp inspect_bucket(%{key_found: false} = state),
    do: {:ok, 0, state.limit, state.limit, state.next_bucket_time, nil, nil}
  defp inspect_bucket(%{key_found: true} = state) do
    [{_, count, created_at, updated_at}] = :ets.lookup(state.table, state.key)
    {rtype, used, remaining} = calculate_bucket_result(state.limit, count)
    {
      rtype, used, remaining, state.limit,
      state.next_bucket_time, created_at, updated_at
    }
  end

  defp calculate_bucket_result(limit, count) when limit >= count,
    do: {:ok, count, limit - count}
  defp calculate_bucket_result(limit, _),
    do: {:error, limit, 0}
end
