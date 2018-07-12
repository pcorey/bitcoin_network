defmodule Log do
  def log(message) do
    [:light_black, "[#{inspect(self())}] ", :reset, message]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
