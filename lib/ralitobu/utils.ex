defmodule Ralitobu.Utils do
  @moduledoc "Utility functions for Ralitobu"

  @compile {:inline, ts: 0, match_spec: 2}

  @doc false
  def ts,
    do: :erlang.system_time(:milli_seconds)

  @doc false
  # fun do {{bucket_number, bid},_,_,_} when bid == ^id -> true end
  def match_spec(:delete, id),
    do: [{{{:"$1", :"$2"}, :_, :_, :_}, [{:==, :"$2", id}], [true]}]

  @doc false
  # fun do {_,_,_,updated_at} when updated_at < (^now_ts - ^timeout) -> true end
  def match_spec(:prune, now_ts, timeout),
    do: [{{:_, :_, :_, :"$1"}, [{:<, :"$1", {:-, now_ts, timeout}}], [true]}]
end
