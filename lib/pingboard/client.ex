defmodule Pingboard.Client do
  use GenServer

  defstruct client_id: nil, client_secret: nil, access_token: nil

  @type client_id :: binary
  @type client_secret :: binary

  @type t :: %Pingboard.Client{client_id: client_id, client_secret: client_secret}

  @endpoint "https://app.pingboard.com"

  ## Client API

  def start_link(client_id, client_secret, opts \\ []) do
    GenServer.start_link(__MODULE__, %Pingboard.Client{client_id: client_id, client_secret: client_secret}, opts)
  end

  def get_groups(pid) do
    GenServer.call(pid, :get_groups)
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

  def handle_call(:get_groups, _from, state) do
    url = "#{@endpoint}/api/v2/groups"

    access_token = Pingboard.TokenHolder.token

    response = HTTPoison.get!(url, %{"Authorization" => "Bearer #{access_token}"})
    case response do
      %HTTPoison.Response{body: body,headers: _header, status_code: 200} ->
        group_response = Poison.Parser.parse!(body)
        {:reply, group_response, state}
      _ ->
        {:stop, "Unhandled Response", %{}}
    end
  end
end