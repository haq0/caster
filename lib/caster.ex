defmodule Caster do
  @moduledoc """
  An Elixir wrapper for the PodcastIndex API.
  """

  alias Caster.Search
  alias Caster.Auth

  @doc """
  Delegates to Caster.Search.by_term/3
  """
  defdelegate search(query, api_key, api_secret), to: Search, as: :by_term

  @doc """
  Delegates to Caster.Search.by_title/3
  """
  defdelegate search_by_title(title, api_key, api_secret), to: Search, as: :by_title

  @doc """
  Delegates to Caster.Search.by_person/3
  """
  defdelegate search_by_person(person, api_key, api_secret), to: Search, as: :by_person

  @doc """
  Delegates to Caster.Search.list_titles/1
  """
  defdelegate list_titles(results), to: Search
end
