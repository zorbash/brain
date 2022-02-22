defmodule NervesLivebook.Scenes.Main do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives

  @font_size 19
  @weather_api_endpoint "http://v2.wttr.in/London?format=%t"
  # 25 minutes
  @refresh_every 25 * 60 * 1_000

  def init(_, _) do
    timer = Process.send_after(self(), :update, 1_000)

    Process.register(self(), :main_scene)

    # Reset the screen
    graph =
      Graph.build(font_size: @font_size, font: :roboto, theme: :light)
      |> rectangle(config()[:size], fill: :white)

    {:ok, %{graph: graph, timer: timer}, push: graph}
  end

  def handle_info(:update, %{timer: timer}) do
    graph = update_graph()

    Process.cancel_timer(timer)
    timer = Process.send_after(self(), :update, @refresh_every)

    {:noreply, %{graph: graph, timer: timer}, push: graph}
  end

  def handle_info(:update_once, _state) do
    graph = update_graph()

    {:noreply, %{graph: graph}, push: graph}
  end

  def update_graph do
    note = NervesLivebook.Notes.random()

    Graph.build(font_size: @font_size, font: :roboto, theme: :light)
    |> rectangle(config()[:size], fill: :white)
    |> header()
    |> body(note)
    |> footer(note)
  end

  defp header(graph) do
    # TODO: Move timezone to config
    %{month: month} = now = Timex.now("Europe/London")

    quarter = ceil(month / 3.0)
    {_year, week} = Timex.iso_week(now)
    {:ok, datetime} = Timex.format(now, "%a %e %b %R", :strftime)

    graph
    |> rectangle({width(), 24}, fill: :black)
    |> text("Q#{quarter} | W#{week}", font_size: 18, fill: :white, t: {5, 17}, text_align: :left)
    |> text(temperature(), font_size: 18, fill: :white, t: {165, 17}, text_align: :left)
    |> text(datetime, font_size: 18, fill: :white, t: {393, 17}, text_align: :right)
  end

  defp body(graph, %{text: text}) do
    graph
    |> text(FontMetrics.wrap(truncate(text, 400), width() - 40, @font_size, metric()),
      fill: :black,
      t: {20, 60}
    )
  end

  defp footer(graph, %{author: author}) do
    graph
    |> text("— #{truncate(author, 80)}", fill: :red, t: {20, height() - 30})
  end

  defp config do
    Application.get_env(:nerves_livebook, :viewport)
  end

  defp width, do: config()[:size] |> elem(0)
  defp height, do: config()[:size] |> elem(1)

  defp metric, do: Scenic.Cache.Static.FontMetrics.get(:roboto)

  defp temperature do
    case :httpc.request(String.to_charlist(@weather_api_endpoint)) do
      {:ok, {_status, _headers, body}} ->
        body |> :binary.list_to_bin()

      _ ->
        ""
    end
  end

  defp truncate(string, max_length) do
    if String.length(string) > max_length do
      "#{string |> String.slice(0, max_length)}…"
    else
      string
    end
  end
end
