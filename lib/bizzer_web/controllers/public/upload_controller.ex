defmodule BizzerWeb.Public.UploadController do
  use BizzerWeb, :controller

  alias Bizzer.{AdimageAction, ImageUtil}

  def adimage(conn, %{"upload_file" => upload_file}) do
    {:ok, image} = AdimageAction.insert(%{origin_url: upload_file.path}, :manual)
    json(conn, %{file_name: _file_name(image.public_url), file_path: image.public_url})
  end

  def generic(conn, %{"upload_file" => upload_file}) do
    {:ok, file} = ImageUtil.store(upload_file.path, "generic", :hq)
    json(conn, %{file_name: _file_name(file), file_path: file})
  end

  def avatar(conn, %{"upload_file" => upload_file}) do
    {:ok, file} = ImageUtil.store(upload_file.path, "avatars", :lq)
    json(conn, %{file_name: _file_name(file), file_path: file})
  end

  def cover(conn, %{"upload_file" => upload_file}) do
    {:ok, file} = ImageUtil.store(upload_file.path, "covers", :hq)
    json(conn, %{file_name: _file_name(file), file_path: file})
  end

  defp _file_name(file), do: Path.basename(file)
end
