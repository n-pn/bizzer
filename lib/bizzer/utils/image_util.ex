defmodule Bizzer.ImageUtil do
  @root Path.join(__DIR__, "../../../")

  def store(input_file, folder \\ "storage", quality \\ :mq) when quality in [:hq, :mq, :lq] do
    input_path = input_file
    output_file = "/uploads/#{folder}/" <> rand_file() <> ".jpg"
    output_path = Path.join(@root, output_file)

    quality =
      case quality do
        :hq -> "1080x1080>"
        :mq -> "640x640>"
        :lq -> "320x320>"
      end

    {output, _} =
      _magick("convert", [
        input_path,
        "-auto-orient",
        "-resize",
        quality,
        "-format",
        "jpg",
        output_path
      ])

    if output == "", do: {:ok, output_file}, else: {:error, output}
  end

  def fetch(url, folder \\ "storage") do
    case HTTPoison.get(url) do
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      {:ok, %{body: nil}} ->
        {:error, "File not found"}

      {:ok, %HTTPoison.Response{headers: headers, body: image}} ->
        ext = image_ext(headers)
        static_url = "/uploads/#{folder}/#{rand_file()}.#{ext}"

        case File.write(Path.join(@root, static_url), image) do
          :ok -> {:ok, static_url}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp image_ext(headers, default \\ "jpg") do
    headers
    |> Enum.into(%{})
    |> Map.get("Content-Type", "image/jpeg")
    |> MIME.extensions()
    |> List.first() || default
  end

  @watermark Path.join(__DIR__, "../../../assets/static/img/watermark.png")
  @width 150
  @height 60

  def auto_watermark(input_file) do
    {width, height} = image_size(input_file)
    x_offset = rand_size(width - @width)
    y_offset = rand_size(height - @height)
    watermark(input_file, x_offset, y_offset)
  end

  def watermark(input_file, x_offset, y_offset) do
    input_path = Path.join(@root, input_file)
    output_file = "/uploads/images/#{rand_file()}.jpg"
    output_path = Path.join(@root, output_file)

    {output, _} =
      _magick("composite", [
        "-gravity",
        "NorthWest",
        "-geometry",
        "+#{x_offset}+#{y_offset}",
        "-format",
        "jpg",
        @watermark,
        input_path,
        output_path
      ])

    if output == "", do: {:ok, output_file}, else: {:error, output}
  end

  def image_size(image_file) do
    image_path = Path.join(@root, image_file)

    {output, _} = _magick("identify", ["-ping", "-format", ~s(%w %h), image_path])

    [width, height] = output |> String.split(" ") |> Enum.map(&String.to_integer(&1))

    {width, height}
  end

  defp rand_file(), do: Bizzer.RandUtil.string(8)
  defp rand_size(max), do: :rand.uniform(max + 1) - 1

  defp _magick(tool, args) do
    case :os.type() do
      {:win32, :nt} ->
        System.cmd("magick", [tool] ++ args)

      _ ->
        System.cmd(tool, args)
    end
  end
end
