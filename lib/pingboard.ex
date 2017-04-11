defmodule Pingboard do

  @endpoint Application.get_env(:pingboard, :endpoint)
  @moduledoc """
  Documentation for Pingboard.
  """

  def endpoint_url(url) do
    @endpoint <> url
  end

end
