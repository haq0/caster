defmodule Caster.Search do
  @moduledoc """
  Handles various search operations for the PodcastIndex API.
  """

  use HTTPoison.Base
  alias Caster.Auth

  @base_url "https://api.podcastindex.org/api/1.0"

  @doc """
  Searches podcasts by general term.

  ## Parameters
    - query: String to search for
    - api_key: Your PodcastIndex API key
    - api_secret: Your PodcastIndex API secret

  ## Examples

      iex> Caster.Search.by_term("elixir", api_key, api_secret)
      {:ok, %{feeds: [%PodcastFeed{}], count: 1}}
  """
  def by_term(query, api_key, api_secret) do
    make_search_request("/search/byterm", query, api_key, api_secret)
  end

  @doc """
  Searches podcasts by exact title.

  ## Parameters
    - title: Podcast title to search for
    - api_key: Your PodcastIndex API key
    - api_secret: Your PodcastIndex API secret

  ## Examples

      iex> Caster.Search.by_title("Everything Everywhere Daily", api_key, api_secret)
      {:ok, %{feeds: [%PodcastFeed{}], count: 1}}
  """
  def by_title(title, api_key, api_secret) do
    make_search_request("/search/bytitle", title, api_key, api_secret)
  end

  @doc """
  Searches podcasts by person (host, guest, etc.).

  ## Parameters
    - person: Name of person to search for
    - api_key: Your PodcastIndex API key
    - api_secret: Your PodcastIndex API secret

  ## Examples

      iex> Caster.Search.by_person("Klaus Schwab", api_key, api_secret)
      {:ok, %{feeds: [%PodcastFeed{}], count: 1}}
  """
  def by_person(person, api_key, api_secret) do
    make_search_request("/search/byperson", person, api_key, api_secret)
  end

  # Private helpers

  defp make_search_request(endpoint, query, api_key, api_secret) do
    url = @base_url <> endpoint <> "?q=" <> URI.encode(query)
    headers = Auth.build_headers(api_key, api_secret)

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parsed = Jason.decode!(body)
        {:ok, parse_search_response(parsed)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("Response body: #{body}")
        {:error, "Request failed with status code: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  @doc """
  Parses a raw search response into a more usable format.
  """
  def parse_search_response(%{"feeds" => feeds, "count" => count} = _response) do
    parsed_feeds = Enum.map(feeds, &parse_feed/1)
    %{
      feeds: parsed_feeds,
      count: count
    }
  end

  @doc """
  Parses a single feed entry into a more structured format.
  """
  def parse_feed(feed) do
    %{
      id: feed["id"],
      title: feed["title"],
      url: feed["url"],  # This is the RSS feed URL
      feed_url: feed["url"],  # Alias for clarity
      website_url: feed["link"],  # The podcast's website URL
      description: feed["description"],
      author: feed["author"],
      image: feed["image"],
      categories: Map.values(feed["categories"] || %{}),
      language: feed["language"],
      episode_count: feed["episodeCount"]
    }
  end

  @doc """
  Gets a simple list of podcast titles from search results.

  ## Examples

      iex> {:ok, results} = Caster.Search.by_term("elixir", key, secret)
      iex> Caster.Search.list_titles(results)
      ["Elixir Talk", "Thinking Elixir"]
  """
  def list_titles(%{feeds: feeds}) do
    Enum.map(feeds, & &1.title)
  end
end
