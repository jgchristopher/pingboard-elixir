defmodule Pingboard do


  @moduledoc """
  A simple and naïve attempt at an elixir client for the Pingboard API.(http://docs.pingboard.apiary.io/#)

  ```
    {:ok, client} = Pingboard.new(<your client id>, <your client secret>)

    groups = Pingboard.Client.get_groups(client)
    users = Pingboard.Client.get_users(client, %Pingboard.Types.Group{id: "1366"})

  """
  def new(client_id, client_secret) do
    Pingboard.Client.start_link(client_id, client_secret)
  end

end
