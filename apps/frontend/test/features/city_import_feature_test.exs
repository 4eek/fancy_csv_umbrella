defmodule TestFeatureTest do
  use Frontend.FeatureCase, async: false
  use Frontend.BackgroundJobCleanup

  @fixture_path "test/fixtures/mixed_cities.csv"

  defp assert_jobs_table(session) do
    session
    |> assert_has(css(".table .id", text: "1"))
    |> assert_has(css(".table .filename", text: "mixed_cities.csv"))
    |> assert_has(css(".table .ok", text: "2"))
    |> assert_has(css(".table .error", text: "1"))
    |> assert_has(css(".table .output a", text: "Download"))
  end

  setup do
    {:ok, sessions: [start_session(), start_session()]}
  end

  test "importing a csv", %{sessions: [session_1, session_2]} do
    session_1
    |> visit(city_import_path(@endpoint, :index))

    session_2
    |> visit(city_import_path(@endpoint, :new))
    |> fill_in(file_field("city_import[file]"), with: @fixture_path)
    |> click(button("Submit"))
    |> assert_jobs_table

    session_1
    |> assert_jobs_table

    session_2
    |> click(link("Download"))

    assert has_text?(session_2, "name,url,errors\nNatal,,url can't be blank")
  end
end
