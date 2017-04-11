defmodule Pingboard.Group do
    defstruct id: nil, name: nil, users: nil

    def get_with_users(group) do
      url = Pingboard.endpoint_url("/api/v2/groups/#{group.id}?include=users")


  end
end
