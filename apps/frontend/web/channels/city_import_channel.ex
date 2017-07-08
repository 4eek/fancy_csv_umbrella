defmodule Frontend.CityImportChannel do
  use Phoenix.Channel

  def join("city_import:status", _message, socket) do
    {:ok, socket}
  end
end
