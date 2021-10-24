defmodule NervesLivebook.Notes do
  @notes :nerves_livebook
                  |> Application.app_dir("priv")
                  |> Path.join("notes/books.json")
                  |> File.read!()
                  |> Jason.decode!(keys: :atoms)
                  |> Enum.flat_map(fn %{author: author, title: title, highlights: highlights} ->
                    for %{text: text} <- highlights,
                        do: %{author: author, title: title, text: text}
                  end)

  def all, do: @notes

  def random do
    @notes |> Enum.random()
  end
end
