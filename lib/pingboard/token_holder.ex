defmodule Pingboard.TokenHolder do

  # access token is valid for 7200 seconds
  @max_age 72000000000

  def start_link(client_id,client_secret) do
    # Start an Agent to store the client_id,client_secret,access_token, and time the token was retrieved
    Agent.start_link(
      fn() ->
        {access_token, retrieved} = get_token(client_id, client_secret)
        {client_id,client_secret,access_token,retrieved}
      end,
      name: __MODULE__)
  end

  def token do
    Agent.get_and_update(
        __MODULE__,
        fn(state={client_id,client_secret,access_token,retrieved}) ->
            age = :timer.now_diff(:os.timestamp, retrieved)
            if(age < @max_age) do
                {access_token,state}
            else
                {access_token, retrieved} = get_token(client_id, client_secret)
                {access_token, {client_id,client_secret,access_token, retrieved}}
            end
        end)
  end

  defp get_token(client_id,client_secret) do
    url = Pingboard.Client.endpoint_url("/oauth/token?grant_type=client_credentials")
    response = HTTPoison.post!(url, {:form, [client_id: client_id, client_secret: client_secret]}, %{"Content-type" => "application/x-www-form-urlencoded"})
    case response do
      %HTTPoison.Response{body: body,headers: _header, status_code: 200} ->
        token_response = Poison.Parser.parse!(body)
        {token_response["access_token"],:os.timestamp}
      %HTTPoison.Response{body: body, headers: _header, status_code: 401} ->
        {:error, Poison.Parser.parse!(body)}
    end

  end

end
