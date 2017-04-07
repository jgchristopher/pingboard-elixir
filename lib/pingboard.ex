defmodule Pingboard do
  import Pingboard.Client
  
  @moduledoc """
  Documentation for Pingboard.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Pingboard.hello
      :world

  """
  @spec sync(Pingboard.Request.t, Pingboard.Client.t) :: map
  def sync(request, client) do
    #response = do_request(client, request)
    #json(response.body)
  end

  defp json(body), do: Poison.Parser.parse!(body)
  
end
