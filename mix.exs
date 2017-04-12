defmodule Pingboard.Mixfile do
  use Mix.Project

  def project do
    [app: :pingboard,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :exconstructor]]
  end

  defp deps do
    [{:httpoison, "~> 0.11"},
     {:poison, "~> 3.0.0"},
     {:exconstructor, "~> 1.1.0"}
    ]
  end

  defp description do
    """
      A simple and naïve attempt at an elixir client for the Pingboard API.(http://docs.pingboard.apiary.io/#)

      ```
        {:ok, client} = Pingboard.new(<your client id>, <your client secret>)

        groups = Pingboard.Client.get_groups(client)
        users = Pingboard.Client.get_users(client, %Pingboard.Types.Group{id: "1366"})
      ```
    """
  end

  defp package do
    [# These are the default files included in the package
     name: :pingboard,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["John Christopher"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/jgchristopher/pingboard-elixir"]
  end
end
