defmodule Ralitobu.Bucket.State do
  @moduledoc """
  Holds the bucket state while processing the call
  """

  alias Ralitobu.Utils

  @compile {:inline, stamps: 2, next_bucket_time: 3}

  defstruct ~w(
    action table
    id limit lifetime
    timestamp key next_bucket_time
    key_found
  )a

  @doc false
  def init(action, table, id, limit, lifetime) do
    {ts, bucket_time} = stamps(lifetime, Utils.ts)
    nbt = next_bucket_time(bucket_time, lifetime, ts)
    %__MODULE__{
      action: action, table: table,
      id: id, limit: limit, lifetime: lifetime,
      timestamp: ts, key: {bucket_time, id},
      next_bucket_time: nbt
    }
  end

  defp stamps(lifetime, ts),
    do: {ts, trunc(ts / lifetime)}

  defp next_bucket_time(bucket_time, lifetime, ts),
    do: (bucket_time * lifetime) + lifetime - ts
end
