defmodule Pingboard.Client do
  use GenServer

  defstruct client_id: nil, client_secret: nil, access_token: nil

  @type client_id :: binary
  @type client_secret :: binary

  @type t :: %Pingboard.Client{client_id: client_id, client_secret: client_secret}

  ## Client API

  def start_link(client_id, client_secret, opts \\ []) do
    GenServer.start_link(__MODULE__, %Pingboard.Client{client_id: client_id, client_secret: client_secret}, opts)
  end

  def get_groups(pid, include_users \\ false) do
    GenServer.call(pid, {:get_groups, include_users}, 15000)
  end

  def get_group_users(pid, group) do
    GenServer.call(pid, {:get_group_users, group}, 15000)
  end

  ## Server API
  def init(%Pingboard.Client{client_id: client_id, client_secret: client_secret}) do
    case Pingboard.TokenHolder.start_link(client_id, client_secret) do
      {:ok, _} ->
        {:ok, %{}}
      {:error, reason} ->
        {:stop, reason, %{}}
    end
  end

  def handle_call({:get_groups, include_users}, _from, state) do
    groups_endpoint =
      case include_users do
        true -> "/api/v2/groups?include=users"
        false -> "/api/v2/groups"
      end
    url = Pingboard.endpoint_url(groups_endpoint)# "#{@endpoint}/api/v2/groups"

    access_token = Pingboard.TokenHolder.token

    response = HTTPoison.get!(url, %{"Authorization" => "Bearer #{access_token}"})
    case response do
      %HTTPoison.Response{body: body,headers: _header, status_code: 200} ->
        group_response = Poison.decode!(body, as: %{"groups" => [%Pingboard.Group{}]})
        #Poison.Parser.parse!(body)
        {:reply, group_response["groups"], state}
      _ ->
        {:stop, "Unhandled Response", %{}}
    end
  end

  def handle_call({:get_group_users, group}, _from, state) do
    url = Pingboard.endpoint_url("/api/v2/groups/#{group.id}?include=users")

    access_token = Pingboard.TokenHolder.token

    response = HTTPoison.get!(url, %{"Authorization" => "Bearer #{access_token}"})
    case response do
      %HTTPoison.Response{body: body,headers: _header, status_code: 200} ->
        group_response = Poison.decode!(body, as: %{"groups" => [%Pingboard.Group{}]})
          #Poison.Parser.parse!(body)
        [users|_] = group_response["groups"]
        {:reply, users, state}
      _ ->
        {:stop, "Unhandled Response", %{}}
    end
  end

end
