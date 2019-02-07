defmodule Bizzer.AdimageAction do
  use Bizzer, :repo
  alias Bizzer.{Adimage, ImageUtil}

  @doc "select or create a new one if not found"
  def crelect(origin_url, origin_src) do
    case Repo.get_by(Adimage, origin_url: origin_url) do
      nil ->
        struct = %{origin_src: origin_src, origin_url: origin_url}

        case insert(struct, :import) do
          {:ok, adimage} -> adimage
          {:error, _} -> nil
        end

      adimage ->
        adimage
    end
  end

  def insert(attrs, type) when type in [:manual, :import] do
    %Adimage{}
    |> Adimage.changeset(attrs, type)
    |> Repo.insert()
  end

  def precache(%{origin_url: origin_url, static_url: nil} = struct) do
    case ImageUtil.fetch(origin_url) do
      {:error, reason} ->
        {:error, reason}

      {:ok, static_url} ->
        struct
        |> Adimage.changeset(%{static_url: static_url}, :precache)
        |> Repo.update()
    end
  end

  def precache(struct), do: {:ok, struct}

  def watermark(%Adimage{} = struct, attrs) do
    struct
    |> Adimage.changeset(attrs, :watermark)
    |> Repo.update()
  end

  def delete(adimage_id) do
    from(r in Adimage, where: r.id == ^adimage_id)
    |> Repo.delete_all()
  end
end
