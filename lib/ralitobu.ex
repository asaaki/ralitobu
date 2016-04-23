defmodule Ralitobu do
  @moduledoc """
  Rate Limiter with Token Bucket algorithm

  Usage information in the `README.md`
  """

  use Application
  alias Ralitobu.{Mixfile, Server}

  @doc "Starts the application"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(Server, [])]
    opts = [strategy: :one_for_one, name: Ralitobu.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc "Starts a new server with given config and options"
  def start_server([table_name: _] = config, [name: _] = opts),
    do: Server.start(config, opts)

  # interface

  @doc "Checkout a token from a given bucket `id` with `limit` and `lifetime`"
  def checkout(id, limit, lifetime),
    do: checkout(Server, id, limit, lifetime)

  @doc "Checkout a token from a given bucket `id` with `limit` and `lifetime` (for a specific `server`)"
  def checkout(server, id, limit, lifetime),
    do: GenServer.call(server, {:checkout, id, limit, lifetime})

  @doc "Inspects a given bucket `id` with `limit` and `lifetime`"
  def inspect(id, limit, lifetime),
    do: inspect(Server, id, limit, lifetime)

  @doc "Inspects a given bucket `id` with `limit` and `lifetime` (for a specific `server`)"
  def inspect(server, id, limit, lifetime),
    do: GenServer.call(server, {:inspect, id, limit, lifetime})

  @doc "Deletes a given bucket `id`"
  def delete(id),
    do: delete(Server, id)

  @doc "Deletes a given bucket `id` (for a specific `server`)"
  def delete(server, id),
    do: GenServer.call(server, {:delete, id})

  @doc """
  Checkout a token from a given bucket `id` with `limit` and `lifetime`
  and sends the result to a given target `pid`
  """
  def async_checkout(id, limit, lifetime, pid),
    do: async_checkout(Server, id, limit, lifetime, pid)

  @doc """
  Checkout a token from a given bucket `id` with `limit` and `lifetime`
  and sends the result to a given target `pid`
  (for a specific `server`)
  """
  def async_checkout(server, id, limit, lifetime, pid),
    do: GenServer.call(server, {:async_checkout, id, limit, lifetime, pid})

  @doc """
  Inspects a given bucket `id` with `limit` and `lifetime`
  and sends the result to a given target `pid`
  """
  def async_inspect(id, limit, lifetime, pid),
    do: async_inspect(Server, id, limit, lifetime, pid)

  @doc """
  Inspects a given bucket `id` with `limit` and `lifetime`
  and sends the result to a given target `pid`
  (for a specific `server`)
  """
  def async_inspect(server, id, limit, lifetime, pid),
    do: GenServer.call(server, {:async_inspect, id, limit, lifetime, pid})

  @doc """
  Deletes a given bucket `id`
  and sends the result to a given target `pid`
  """
  def async_delete(id, pid),
    do: async_delete(Server, id, pid)

  @doc """
  Deletes a given bucket `id`
  and sends the result to a given target `pid`
  (for a specific `server`)
  """
  def async_delete(server, id, pid),
    do: GenServer.call(server, {:async_delete, id, pid})

  @version Mixfile.project[:version]
  @doc "Returns the current version of `Ralitobu`"
  def version, do: @version
end
