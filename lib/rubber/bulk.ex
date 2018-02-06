defmodule Rubber.Bulk do
  @moduledoc """
  The bulk API makes it possible to perform many index/delete operations in a single API call.

  [Elastic documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html)
  """
  import Rubber.HTTP, only: [prepare_url: 2]
  alias Rubber.HTTP

  @doc """
  Excepts a list of actions and sources for the `lines` parameter.

  ## Examples

      iex> Rubber.Bulk.post("http://localhost:9200", [%{index: %{_id: "1"}}, %{user: "kimchy"}], index: "twitter", type: "tweet")
      {:ok, %HTTPoison.Response{...}}
  """
  @spec post(
          elastic_url :: String.t(),
          lines :: list,
          opts :: Keyword.t(),
          query_params :: Keyword.t()
        ) :: HTTP.resp()
  def post(elastic_url, lines, options \\ [], query_params \\ []) do
    data =
      Enum.reduce(lines, [], fn l, acc -> ["\n", Poison.encode!(l) | acc] end)
      |> Enum.reverse()
      |> IO.iodata_to_binary()

    path =
      Keyword.get(options, :index)
      |> make_path(Keyword.get(options, :type), query_params)

    elastic_url
    |> prepare_url(path)
    |> HTTP.put(data)
  end

  @doc """
  Deprecated: use `post/4` instead.
  """
  @spec post_to_iolist(
          elastic_url :: String.t(),
          lines :: list,
          opts :: Keyword.t(),
          query_params :: Keyword.t()
        ) :: HTTP.resp()
  def post_to_iolist(elastic_url, lines, options \\ [], query_params \\ []) do
    IO.warn(
      "This function is deprecated and will be removed in future releases; use Rubber.Bulk.post/4 instead."
    )

    (elastic_url <>
       make_path(Keyword.get(options, :index), Keyword.get(options, :type), query_params))
    |> HTTP.put(Enum.map(lines, fn line -> Poison.encode!(line) <> "\n" end))
  end

  @doc """
  Same as `post/4` but instead of sending a list of maps you must send raw binary data in
  the format described in the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html).
  """
  @spec post_raw(
          elastic_url :: String.t(),
          raw_data :: String.t(),
          opts :: Keyword.t(),
          query_params :: Keyword.t()
        ) :: HTTP.resp()
  def post_raw(elastic_url, raw_data, options \\ [], query_params \\ []) do
    (elastic_url <>
       make_path(Keyword.get(options, :index), Keyword.get(options, :type), query_params))
    |> HTTP.put(raw_data)
  end

  @doc false
  def make_path(index_name, type_name, query_params) do
    path = make_base_path(index_name, type_name)

    case query_params do
      [] -> path
      _ -> HTTP.append_query_string(path, query_params)
    end
  end

  defp make_base_path(nil, nil), do: "/_bulk"
  defp make_base_path(index_name, nil), do: "/#{index_name}/_bulk"
  defp make_base_path(index_name, type_name), do: "/#{index_name}/#{type_name}/_bulk"
end
