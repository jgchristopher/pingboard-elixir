defmodule Pingboard.Client do
  use GenServer
  alias Pingboard.Types.Group
  alias Pingboard.Types.User

  #@endpoint Application.get_env(:pingboard, :endpoint)
  @endpoint "https://app.pingboard.com"

  defstruct client_id: nil, client_secret: nil, access_token: nil

  ## Client API

  def start_link(client_id, client_secret, opts \\ []) do
    GenServer.start_link(__MODULE__, %Pingboard.Client{client_id: client_id, client_secret: client_secret}, opts)
  end

  def get_groups(pid, include_users \\ false) do
    GenServer.call(pid, {:get_groups, include_users}, 15000)
  end

  def get_users(pid) do
    GenServer.call(pid, {:get_users}, 15000)
  end

  def get_users(pid, group) do
    GenServer.call(pid, {:get_users, group}, 15000)
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

    url = endpoint_url(groups_endpoint)
    handle_get_response(url, fn(body) ->
      group_response = Poison.decode!(body)
      groups = group_response["groups"]

      groups = Enum.map(groups, fn(group) -> Group.new(group) end)

      {:reply, groups, state}
    end)
  end

  def handle_call({:get_users}, _from, state) do
    url = endpoint_url("/api/v2/users")

    handle_get_response(url, fn(body) ->
      users_response = Poison.decode!(body)
      users =
        users_response["users"]
        |> Enum.map(fn(user) -> User.new(user) end)
      {:reply, users, state}
    end)
  end

  def handle_call({:get_users, group}, _from, state) do
    url = endpoint_url("/api/v2/groups/#{group.id}?include=users")

    handle_get_response(url, fn(body) ->
      group_response = Poison.decode!(body)
      users = group_response["linked"]["users"]
      users = Enum.map(users, fn(user) -> User.new(user) end)
      {:reply, users, state}
    end)
  end

  ## Helpers
  def endpoint_url(url) do
    @endpoint <> url
  end

  defp handle_get_response(url, callback) do
    access_token = Pingboard.TokenHolder.token
    response = HTTPoison.get!(url, %{"Authorization" => "Bearer #{access_token}"})
    case response do
      %HTTPoison.Response{body: body,headers: _header, status_code: 200} ->
        callback.(body)
      _ ->
        {:stop, "Unhandled Response", %{}}
    end
  end



end
