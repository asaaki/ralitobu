defmodule Ralitobu.Config do
  @moduledoc """
  Configuration helper module
  """

  @otp_app :ralitobu
  @timeout 90_000_000
  @cleanup_rate 60_000
  @table_name :ralitobu_table

  @doc false
  def parse(config) do
    {
      get(config, :table_name),
      get(config, :timeout),
      get(config, :cleanup_rate),
    }
  end

  defp get(config, key),
    do: Dict.get(config, key, app_env(key))

  for key <- ~w(timeout cleanup_rate table_name)a do
    default_value = Module.get_attribute(__MODULE__, key)
    defp app_env(unquote(key)),
      do: Application.get_env(@otp_app, unquote(key), unquote(default_value))
  end
end
