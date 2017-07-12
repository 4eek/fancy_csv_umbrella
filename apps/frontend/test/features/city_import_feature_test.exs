defmodule TestFeatureTest do
  use Frontend.FeatureCase, async: false
  use Frontend.BackgroundJobCleanup

  test "uploads, imports a csv, and provides output csv", %{session: session} do
    session
    |> visit(city_import_path(@endpoint, :new))
    |> fill_in(file_field("city_import[file]"), with: "test/fixtures/cities.csv")
    |> click(button("Submit"))
    |> assert_has(css(".table .id", text: "1"))
    |> assert_has(css(".table .filename", text: "cities.csv"))
    |> assert_has(css(".table .ok", text: "3"))
    |> assert_has(css(".table .error", text: "0"))
    |> assert_has(css(".table .output a", text: "Download"))
    |> click(link("Download"))
    |> has_text?("name,url,errors")
  end
end
