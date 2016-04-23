# Ralitobu

**The Rate Limiter with Token Bucket algorithm**

This is a fork of [ExRated](https://github.com/grempe/ex_rated), but with some changes:

- the checkout and inspection always return the same result tuple
- asynchronous counterparts for checkout, inspect and delete
- configuration can be given on initialization and not only via application environment
  (useful when starting multiple rate limiters with different settings)

## Installation

In `mix.exs`:

```elixir
  def deps do
    [{:ralitobu, "~> 0.1.0"}]
  end
```

```elixir
  def application do
    [applications: [:ralitobu]]
  end
```

## Usage

### Checkouts

- `Ralitobu.checkout/3` (`Ralitobu.checkout(id, limit, lifetime)` using default server)
- `Ralitobu.checkout/4` (`Ralitobu.checkout(server, id, limit, lifetime)`)

The result tuple format:

```elixir
{success, counter, remaining_limit, total_limit, countdown, created_at, updated_at}
```

```elixir
# 1st call:
Ralitobu.checkout("my-bucket", 3, 10_000)
#=> {:ok, 1, 2, 3, 7806, 1461432862194, 1461432862194}

# 3rd call:
Ralitobu.checkout("my-bucket", 3, 10_000)
#=> {:ok, 3, 0, 3, 7799, 1461432862194, 1461432862201}

# 4th call fails (over rate limit):
Ralitobu.checkout("my-bucket", 3, 10_000)
#=> {:error, 3, 0, 3, 7795, 1461432862194, 1461432862200}
```

### Inspection

- `Ralitobu.inspect/3` (`Ralitobu.inspect(id, limit, lifetime)` using default server)
- `Ralitobu.inspect/4` (`Ralitobu.inspect(server, id, limit, lifetime)`)

The result tuple format:

```elixir
{success, counter, remaining_limit, total_limit, countdown, created_at, updated_at}
```

```elixir
# multiple calls do not increment the counter:
Ralitobu.inspect("my-bucket", 3, 10_000)
#=> {:ok, 2, 3, 3, 4132, 1461432862194, 1461432862200}
Ralitobu.inspect("my-bucket", 3, 10_000)
#=> {:ok, 2, 3, 3, 4130, 1461432862194, 1461432862200}

# bucket does not exists:
Ralitobu.inspect("my-other-bucket", 3, 10_000)
#=> {:ok, 0, 3, 3, 9142, nil, nil}
```

### Deletion

- `Ralitobu.delete/1` (`Ralitobu.delete(id)` using default server)
- `Ralitobu.delete/2` (`Ralitobu.delete(server, id)`)

Result is either `:ok` or `:error`, depending if the bucket existed or not.

```elixir
# bucket (still) exists:
Ralitobu.delete("my-bucket")
#=> :ok

# bucket is not present (anymore):
Ralitobu.delete("my-bucket")
#=> :error
```

### New server instance

The application always starts a default server,
but you can run your own instance(s) as well.

`Ralitobu.start_server/2` (`Ralitobu.start_server(configuration, gen_server_opts)`)

```elixir
{:ok, server} = Ralitobu.start_server(
  [table_name: :another_ralitobu_table, timeout: 30_000_000, cleanup_rate: 15_000],
  [name: :another_ralitobu_server]
)
```

You must provide the `name` parameter for the GenServer options,
otherwise it will take the default name and therefore not starting a new server.
Also the `table_name` must be different, too.

### Server configuration

- `table_name` (atom):
  The name of the ETS table
- `timeout` (integer):
  milliseconds; buckets older than _(now - timeout)_ will be cleaned up (based on last update timestamp)
- `cleanup_rate` (integer):
  milliseconds; the interval for the clean up task
