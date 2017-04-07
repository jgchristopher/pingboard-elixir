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
    # need to authenticate with pingboard and store the temporary access_token
    url = "#{@endpoint}/oauth/token?grant_type=client_credentials"
    response = HTTPoison.post!(url, {:form, [client_id: client_id, client_secret: client_secret]}, %{"Content-type" => "application/x-www-form-urlencoded"})
    body = response.body
    IO.inspect body
    token_response = Poison.Parser.parse!(body)
    IO.inspect token_response
    IO.puts token_response["access_token"]
    {:ok, %{client_id: client_id, client_secret: client_secret, access_token: token_response["access_token"]}}    
  end

  def handle_call(:get_groups, _from, stats) do
    url = "#{@endpoint}/api/v2/groups"
    response = HTTPoison.get!(url, %{"Authorization" => "Bearer #{stats[:access_token]}"})
    body = response.body
    IO.inspect body
    group_response = Poison.Parser.parse!(body)
    {:reply, group_response, stats}
  end

end