defmodule Rubber.Index do
  @moduledoc """
  """
  import Rubber.HTTP, only: [prepare_url: 2]
  alias Rubber.HTTP

  @doc false
  def create(elastic_url, name, data) do
    prepare_url(elastic_url, name)
    |> HTTP.put(Poison.encode!(data))
  end

  @doc false
  def delete(elastic_url, name) do
    prepare_url(elastic_url, name)
    |> HTTP.delete
  end

  @doc false
  def get(elastic_url, name) do
    prepare_url(elastic_url, name)
    |> HTTP.get
  end

  @doc false
  def exists?(elastic_url, name) do
    case prepare_url(elastic_url, name) |> HTTP.head do
      {:ok, response} ->
        case response.status_code do
          200 -> {:ok, true}
          404 -> {:ok, false}
        end
      err -> err
    end
  end

  @doc false
  def refresh(elastic_url, name) do
    prepare_url(elastic_url, [name, "_refresh"])
    |> HTTP.post("")
  end
end
