defmodule Caster.Auth do
  @moduledoc """
  Handles authentication for the PodcastIndex API.
  """

  @doc """
  Builds the required authentication headers for PodcastIndex API.

  ## Parameters
    - api_key: Your PodcastIndex API key
    - api_secret: Your PodcastIndex API secret

  ## Returns
    List of tuples containing the required headers
  """
  def build_headers(api_key, api_secret) do
    timestamp = :os.system_time(:second)
    auth_string = "#{api_key}#{api_secret}#{timestamp}"

    hash = :crypto.hash(:sha, auth_string)
    |> Base.encode16(case: :lower)

    [
      {"User-Agent", "Caster Elixir Client"},
      {"X-Auth-Key", api_key},
      {"X-Auth-Date", to_string(timestamp)},
      {"Authorization", hash}
    ]
  end
end
