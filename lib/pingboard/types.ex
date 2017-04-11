defmodule Pingboard.Types do
  defmodule User do
    defstruct id: nil, first_name: nil, last_name: nil, job_title: nil, avatar_urls: [], phone: nil, start_date: nil
    use ExConstructor
  end

  defmodule Group do
    defstruct id: nil, name: nil, memberships_count: nil
    use ExConstructor
  end
end

