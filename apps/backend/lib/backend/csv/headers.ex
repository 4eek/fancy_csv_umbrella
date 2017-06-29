defmodule Backend.Csv.Headers do
  @headers ~w(name url)a

  def valid?(headers) do
    Enum.count(headers) == Enum.count(@headers) &&
    Enum.sort(headers) == Enum.sort(@headers)
  end
end
