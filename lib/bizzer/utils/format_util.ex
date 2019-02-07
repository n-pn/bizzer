defmodule Bizzer.FormatUtil do
  def parse_int(str, default \\ 0)
  def parse_int(nil, default), do: default

  def parse_int(str, default) do
    case Integer.parse(str) do
      :error -> default
      {int, _} -> int
    end
  end

  @doc "Create url friendly strings"

  def slugify(nil), do: ""

  def slugify(input, size \\ 10) do
    input
    |> String.downcase()
    |> remove_accent
    |> String.split(~r/[^[:alnum:]]+/u, trim: true)
    |> Stream.reject(&(&1 == ""))
    |> Stream.take(size)
    |> Enum.join("-")
  end

  @accents "ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚÝàáâãèéêìíòóôõùúýĂăĐđĨĩŨũƠơƯưẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪừỬửỮữỰựỲỳỴỵỶỷỸỹ"
           |> String.split("")

  @no_accents "AAAAEEEIIOOOOUUYaaaaeeeiioooouuyAaDdIiUuOoUuAaAaAaAaAaAaAaAaAaAaAaAaEeEeEeEeEeEeEeEeIiIiOoOoOoOoOoOoOoOoOoOoOoOoUuUuUuUuUuUuUuYyYyYyYy"
              |> String.split("")

  @accent_map Enum.zip(@accents, @no_accents) |> Enum.into(%{})

  @doc "Remove vietnamese accents"
  def remove_accent(input) do
    input
    |> String.split("")
    |> Enum.map(fn char -> Map.get(@accent_map, char, char) end)
    |> Enum.join("")
  end

  @doc "Price pretty format"
  def money_to_vnd(money) do
    money =
      money
      |> Integer.to_charlist()
      |> Enum.reverse()
      |> Enum.chunk_every(3, 3, [])
      |> Enum.join(".")
      |> String.reverse()

    money <> " đ"
  end
end
