defmodule Log.Application do
  use Application

  def start(_type \\ nil, _args \\ nil) do
    children = []

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
